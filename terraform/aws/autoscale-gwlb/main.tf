provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "amis" {
  source = "../modules/amis"
  version_license = var.gateway_version
  amis_url = "https://cgi-cfts.s3.amazonaws.com/gwlb/amis-gwlb.yaml"
}

resource "aws_security_group" "permissive_sg" {
  name_prefix = format("%s_PermissiveSecurityGroup", local.asg_name)
  description = "Permissive security group"
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = format("%s_PermissiveSecurityGroup", local.asg_name)
  }
}

resource "aws_launch_configuration" "asg_launch_configuration" {
  name_prefix = local.asg_name
  image_id = module.amis.ami_id
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  security_groups = [aws_security_group.permissive_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = ( var.enable_cloudwatch ? aws_iam_instance_profile.instance_profile[0].name : "")

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted = var.enable_volume_encryption
  }

  user_data = templatefile("${path.module}/asg_userdata.sh", {
    // script's arguments
    PasswordHash = var.gateway_password_hash,
    EnableCloudWatch = var.enable_cloudwatch,
    EnableInstanceConnect = var.enable_instance_connect,
    Shell = var.admin_shell,
    SICKey = var.gateway_SICKey,
    AllowUploadDownload = var.allow_upload_download,
    BootstrapScript = var.gateway_bootstrap_script
  })
}
resource "aws_autoscaling_group" "asg" {
  name_prefix = local.asg_name
  launch_configuration = aws_launch_configuration.asg_launch_configuration.id
  min_size = var.minimum_group_size
  max_size = var.maximum_group_size
  target_group_arns = var.target_groups
  vpc_zone_identifier = var.subnet_ids
  health_check_grace_period = 0

  tags = concat(
  [
    {
      key = "Name"
      value = format("%s%s", var.prefix != "" ? format("%s-", var.prefix) : "", var.gateway_name)
      propagate_at_launch = true
    },
    {
      key = "x-chkp-tags"
      value = format("management=%s:template=%s:ip-address=%s", var.management_server, var.configuration_template, var.gateways_provision_address_type)
      propagate_at_launch = true
    },
    {
      key = "x-chkp-topology"
      value = "internal"
      propagate_at_launch = true
    },
    {
      key = "x-chkp-solution"
      value = "autoscale_gwlb"
      propagate_at_launch = true
    }
  ],
  local.tags_asg_format
  )
}

data "aws_iam_policy_document" "assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  count = local.create_iam_role
  name_prefix = format("%s-iam_role", local.asg_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  path = "/"
}
data "aws_iam_policy_document" "policy_document" {
  version = "2012-10-17"
  statement {
    actions = ["cloudwatch:PutMetricData"]
    effect = "Allow"
    resources = ["*"]
  }
}
resource "aws_iam_policy" "policy" {
  count = local.create_iam_role
  name_prefix = format("%s-iam_policy", local.asg_name)

  policy = data.aws_iam_policy_document.policy_document.json
}
resource "aws_iam_role_policy_attachment" "attachment" {
  count = local.create_iam_role
  role = aws_iam_role.role[count.index].name
  policy_arn = aws_iam_policy.policy[count.index].arn
}
resource "aws_iam_instance_profile" "instance_profile" {
  count = local.create_iam_role
  name_prefix = format("%s-iam_instance_profile", local.asg_name)
  path = "/"
  role = aws_iam_role.role[count.index].name
}

// Scaling metrics
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name = format("%s_alarm_low", aws_autoscaling_group.asg.name)
  metric_name = "CPUUtilization"
  alarm_description = "Scale-down if CPU < 60% for 10 minutes"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = 300
  evaluation_periods = 2
  threshold = 60
  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  comparison_operator = "LessThanThreshold"
}
resource "aws_autoscaling_policy" "scale_down_policy" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name = format("%s_scale_down", aws_autoscaling_group.asg.name)
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  scaling_adjustment = -1
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name = format("%s_alarm_high", aws_autoscaling_group.asg.name)
  metric_name = "CPUUtilization"
  alarm_description = "Scale-up if CPU > 80% for 10 minutes"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = 300
  evaluation_periods = 2
  threshold = 80
  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  comparison_operator = "GreaterThanThreshold"
}
resource "aws_autoscaling_policy" "scale_up_policy" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name = format("%s_scale_up", aws_autoscaling_group.asg.name)
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  scaling_adjustment = 1
}
