
module "amis" {
  source = "../amis"

  version_license = var.version_license
}

resource "aws_security_group" "tap_sg" {
  description = format("%s Security group", var.resources_tag_name != "" ? var.resources_tag_name : var.instance_name)
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow VXLAN for traffic mirroring"
    protocol = "udp"
    from_port = 4789
    to_port = 4789
    cidr_blocks = ["0.0.0.0/0"]
  }
  name = format("%s_SecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.instance_name) // Group name
  tags = {
    Name = format("%s_SecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.instance_name) // Resource name
  }
}
resource "aws_network_interface" "external-eni" {
  subnet_id = var.external_subnet_id
  security_groups = [aws_security_group.tap_sg.id]
  description = "eth0"
  source_dest_check = false
  tags = {
    Name = format("%s-external_network_interface", var.resources_tag_name != "" ? var.resources_tag_name : var.instance_name)
  }
}
resource "aws_network_interface" "internal-eni" {
  subnet_id = var.internal_subnet_id
  security_groups = [aws_security_group.tap_sg.id]
  description = "eth1"
  source_dest_check = false
  tags = {
    Name = format("%s-internal_network_interface", var.resources_tag_name != "" ? var.resources_tag_name : var.instance_name)
  }
}
resource "aws_eip" "eip" {
  vpc = true
  network_interface = aws_network_interface.external-eni.id
}
resource "aws_instance" "tap_gateway" {
  depends_on = [
    aws_network_interface.external-eni,
    aws_network_interface.internal-eni,
    aws_eip.eip
  ]

  ami = module.amis.ami_id
  tags = {
    Name = var.instance_name
  }
  instance_type = var.instance_type
  key_name = var.key_name

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 100
  }
  network_interface { // external
    network_interface_id = aws_network_interface.external-eni.id
    device_index = 0
  }
  network_interface { // internal
    network_interface_id = aws_network_interface.internal-eni.id
    device_index = 1
  }

  user_data = templatefile("${path.module}/tap_user_data_script.sh", {
    // script's arguments
    RegistrationKey = var.registration_key
    VxlanIds = var.vxlan_id
  })
}

// Create CloudFormation Stack
resource "random_id" "stack_uuid" {
  byte_length = 5
}
resource "aws_cloudformation_stack" "tap_target_and_filter" {
  depends_on = [aws_instance.tap_gateway]
  name = format("traffic-mirror-filter-and-target-%s", random_id.stack_uuid.hex)

  parameters = {
    MirroringNetworkInterfaceId = aws_network_interface.internal-eni.id
    EnvironmentPrefix = var.resources_tag_name
  }
  template_url = "https://cgi-cfts.s3.amazonaws.com/utils/tap_target_and_filter.yaml"
}
locals {
  trafficMirrorTargetId = aws_cloudformation_stack.tap_target_and_filter.outputs["TrafficMirrorTargetId"]
  trafficMirrorFilterId = aws_cloudformation_stack.tap_target_and_filter.outputs["TrafficMirrorFilterId"]
}

// Lambdas
// --- TAP Lambda ---
data "aws_iam_policy_document" "assume_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}
data "aws_iam_policy_document" "tap_lambda_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeInstances",
      "ec2:CreateTags",
      "ec2:DeleteTrafficMirrorSession",
      "ec2:CreateTrafficMirrorSession",
      "ec2:DescribeTrafficMirrorSessions"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role" "tap_lambda_iam_role" {
  name_prefix = "chkp_iam_tap_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_doc.json
}
resource "aws_iam_role_policy" "tap_lambda_policy" {
  policy = data.aws_iam_policy_document.tap_lambda_policy_doc.json
  role = aws_iam_role.tap_lambda_iam_role.id
}
// Lambda Function
resource "random_id" "tap_lambda_uuid" {
  byte_length = 5
}
data "archive_file" "tap_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/tap_lambda.py"
  output_path = "${path.module}/tap_lambda.zip"
}
locals {
  blacklisted_tag_pairs_joined = join(":", [for tag_key in keys(var.blacklist_tags): join("=", [tag_key, var.blacklist_tags[tag_key]])])
}
resource "aws_lambda_function" "tap_lambda" {
  depends_on = [aws_instance.tap_gateway]
  function_name = format("chkp_tap_lambda-%s", random_id.tap_lambda_uuid.hex)
  description = "The TAP lambda creates traffic mirror sessions with the TAP gateway instance, and removes them for blacklisted instances in the VPC."

  filename = "${path.module}/tap_lambda.zip"

  role = aws_iam_role.tap_lambda_iam_role.arn
  handler = "tap_lambda.lambda_handler"
  runtime = "python3.8"
  timeout = 30

  environment {
    variables = {
      VPC_ID = var.vpc_id
      GW_ID = aws_instance.tap_gateway.id
      TM_TARGET_ID = local.trafficMirrorTargetId
      TM_FILTER_ID = local.trafficMirrorFilterId
      VNI = var.vxlan_id
      TAP_BLACKLIST = local.blacklisted_tag_pairs_joined
    }
  }
}
// CloudWatch event - EC2 state change to Running
resource "aws_cloudwatch_event_rule" "on_ec2_running_state" {
  name_prefix = "tap_ec2_running_rule"
  description = "Invoked when an instance changes its state to Running"
  event_pattern = <<PATTERN
  {
    "source": [
      "aws.ec2"
    ],
    "detail-type": [
      "EC2 Instance State-change Notification"
    ],
    "detail": {
      "state": [
        "running"
      ]
    }
  }
  PATTERN
}
resource "aws_cloudwatch_event_target" "associate_ec2_rule" {
  rule = aws_cloudwatch_event_rule.on_ec2_running_state.name
  arn = aws_lambda_function.tap_lambda.arn
}
resource "aws_lambda_permission" "allow_ec2_rule_to_call_tap_lambda" {
  statement_id = "AllowExecutionFromEC2CloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tap_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.on_ec2_running_state.arn
}
// CloudWatch event - Scheduled
resource "aws_cloudwatch_event_rule" "on_schedule" {
  name_prefix = "tap_schedule_rule"
  description = "Invoked every <schedule_scan_interval> minutes"
  schedule_expression = format("rate(%d minutes)", var.schedule_scan_interval)
}
resource "aws_cloudwatch_event_target" "associate_schedule_rule" {
  rule = aws_cloudwatch_event_rule.on_schedule.name
  arn = aws_lambda_function.tap_lambda.arn
}
resource "aws_lambda_permission" "allow_schedule_rule_to_call_tap_lambda" {
  statement_id = "AllowExecutionFromScheduledCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tap_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.on_schedule.arn
}
// TAP Lambda Invocation
data "aws_lambda_invocation" "tap_lambda_invocation" {
  depends_on = [aws_lambda_function.tap_lambda]
  function_name = aws_lambda_function.tap_lambda.function_name
  input = <<JSON
  {
    "deployment_invocation": "true"
  }
  JSON
}

// --- Terminate TAP Lambda ---
data "aws_iam_policy_document" "tap_termination_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DeleteTrafficMirrorSession",
      "ec2:DescribeTrafficMirrorSessions"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role" "terminate_gw_lambda_iam_role" {
  name_prefix = "chkp_iam_tap_termination_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_doc.json
}
resource "aws_iam_role_policy" "tap_termination_policy" {
  policy = data.aws_iam_policy_document.tap_termination_policy_doc.json
  role = aws_iam_role.terminate_gw_lambda_iam_role.id
}
// Lambda Function
resource "random_id" "tap_termination_lambda_uuid" {
  byte_length = 5
}
data "archive_file" "tap_termination_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/tap_termination_lambda.py"
  output_path = "${path.module}/tap_termination_lambda.zip"
}
resource "aws_lambda_function" "tap_termination_lambda" {
  function_name = format("chkp_tap_termination_lambda-%s", random_id.tap_termination_lambda_uuid.hex)
  description = "Manually invoke the termination lambda before destroying the TAP environment. The termination lambda deletes all mirror sessions to the TAP gateway in order to allow destruction."

  filename = "${path.module}/tap_termination_lambda.zip"

  role = aws_iam_role.terminate_gw_lambda_iam_role.arn
  handler = "tap_termination_lambda.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      TM_TARGET_ID = local.trafficMirrorTargetId
      TM_FILTER_ID = local.trafficMirrorFilterId
    }
  }
}
