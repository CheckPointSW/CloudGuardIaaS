provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "amis" {
  source = "../modules/amis"

  version_license = var.standalone_version
  chkp_type = "standalone"
}

module "common_permissive_sg" {
  source = "../modules/common/permissive_sg"

  vpc_id = var.vpc_id
  resources_tag_name = var.resources_tag_name
  gateway_name = var.standalone_name
}

resource "aws_iam_instance_profile" "standalone_instance_profile" {
  count = local.enable_cloudwatch_policy
  path = "/"
  role = aws_iam_role.standalone_iam_role[count.index].name
}

resource "aws_iam_role" "standalone_iam_role" {
  count = local.enable_cloudwatch_policy
  assume_role_policy = data.aws_iam_policy_document.standalone_role_assume_policy_document.json
  path = "/"
}

data "aws_iam_policy_document" "standalone_role_assume_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "attach_cloudwatch_policy" {
  source = "../modules/cloudwatch-policy"
  count = local.enable_cloudwatch_policy
  role = aws_iam_role.standalone_iam_role[count.index].name
  tag_name = var.resources_tag_name != "" ? var.resources_tag_name : var.standalone_name
}
resource "aws_network_interface" "public_eni" {
  subnet_id = var.public_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "eth0"
  source_dest_check = false
  tags = {
    Name = format("%s-external-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.standalone_name) }
}
resource "aws_network_interface" "private_eni" {
  subnet_id = var.private_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "eth1"
  source_dest_check = false
  tags = {
    Name = format("%s-internal-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.standalone_name) }
}

module "common_eip" {
  source = "../modules/common/elastic_ip"

  allocate_and_associate_eip = var.allocate_and_associate_eip
  external_eni_id = aws_network_interface.public_eni.id
  private_ip_address = aws_network_interface.public_eni.private_ip
}

module "common_internal_default_route" {
  source = "../modules/common/internal_default_route"

  private_route_table = var.private_route_table
  internal_eni_id = aws_network_interface.private_eni.id
}

resource "aws_launch_template" "standalone_launch_template" {
  instance_type = var.standalone_instance_type
  key_name = var.key_name
  image_id = module.amis.ami_id
  description = "Initial launch template version"

  iam_instance_profile {
    name = (local.enable_cloudwatch_policy == 1 ? aws_iam_instance_profile.standalone_instance_profile[0].id : "")
  }

  network_interfaces {
    network_interface_id = aws_network_interface.public_eni.id
    device_index = 0
  }

  metadata_options {
    http_tokens = var.metadata_imdsv2_required ? "required" : "optional"
  }

  network_interfaces {
    network_interface_id = aws_network_interface.private_eni.id
    device_index = 1
  }
}

resource "aws_instance" "standalone-instance" {
  launch_template {
    id = aws_launch_template.standalone_launch_template.id
    version = "$Latest"
  }

  disable_api_termination = var.disable_instance_termination

  tags = merge({
    Name = var.standalone_name
  }, var.instance_tags)

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }

  user_data = templatefile("${path.module}/standalone_userdata.yaml", {
    // script's arguments
    Hostname = var.standalone_hostname,
    PasswordHash = local.standalone_password_hash_base64,
    MaintenanceModePassword = local.maintenance_mode_password_hash_base64,
    AllowUploadDownload = var.allow_upload_download,
    EnableCloudWatch = var.enable_cloudwatch,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    AdminSubnet = var.admin_cidr,
    EnableInstanceConnect = var.enable_instance_connect,
    StandaloneBootstrapScript = local.standalone_bootstrap_script64
    AllocateElasticIP = var.allocate_and_associate_eip
    OsVersion = local.version_split
  })
}