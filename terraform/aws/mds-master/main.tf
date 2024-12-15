provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

// --- VPC ---
module "launch_vpc" {
  source = "../modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnets_map = {
    (var.public_subnet_az) = 1
  }
  private_subnets_map = {}
  subnets_bit_length = var.subnets_bit_length
}

module "amis" {
  source = "../modules/amis"

  version_license = var.mds_version
  chkp_type = "mds"
}

resource "aws_security_group" "mds_sg" {
  description = "terraform Multi-Domain Server security group"
  vpc_id = module.launch_vpc.vpc_id
  name_prefix = format("%s_SecurityGroup", var.mds_name)
  // Group name
  tags = {
    Name = format("%s_SecurityGroup", var.mds_name)
    // Resource name
  }
  ingress {
    from_port = 257
    to_port = 257
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 8211
    to_port = 8211
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18191
    to_port = 18191
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18192
    to_port = 18192
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18208
    to_port = 18208
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18210
    to_port = 18210
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18211
    to_port = 18211
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18221
    to_port = 18221
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 18264
    to_port = 18264
    protocol = "tcp"
    cidr_blocks = [var.gateway_addresses]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  ingress {
    from_port = 18190
    to_port = 18190
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  ingress {
    from_port = 19009
    to_port = 19009
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "mds_instance_profile" {
  count = local.use_role
  path = "/"
  role = local.create_iam_role ? join("", module.cme_iam_role.*.cme_iam_role_name) : var.predefined_role
}

resource "aws_network_interface" "external-eni" {
  subnet_id = module.launch_vpc.public_subnets_ids_list[0]
  security_groups = [aws_security_group.mds_sg.id]
  description = "eth0"
  source_dest_check = true
  tags = {
    Name = format("%s-network_interface", var.mds_name)
  }
}

resource "aws_launch_template" "mds_launch_template" {
  instance_type = var.mds_instance_type
  key_name = var.key_name
  image_id = module.amis.ami_id
  description = "Initial launch template version"

  iam_instance_profile {
    name = local.use_role == 1 ? aws_iam_instance_profile.mds_instance_profile[0].id : ""
  }

  metadata_options {
    http_tokens = var.metadata_imdsv2_required ? "required" : "optional"
  }

  network_interfaces {
    network_interface_id = aws_network_interface.external-eni.id
    device_index = 0
  }
}

resource "aws_instance" "mds-instance" {
  launch_template {
    id = aws_launch_template.mds_launch_template.id
    version = "$Latest"
  }

  disable_api_termination = var.disable_instance_termination

  tags = merge({
    Name = var.mds_name
  }, var.instance_tags)

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }

  user_data = templatefile("${path.module}/mds_userdata.yaml", {
    // script's arguments
    Hostname = var.mds_hostname,
    PasswordHash = local.mds_password_hash_base64
    MaintenanceModePassword = local.maintenance_mode_password_hash_base64
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp
    NTPSecondary = var.secondary_ntp
    Shell = var.mds_admin_shell,
    AdminSubnet = var.admin_cidr
    IsPrimary = local.primary_mds
    IsSecondary = local.secondary_mds
    SICKey = local.mds_SICkey_base64,
    EnableInstanceConnect = var.enable_instance_connect
    BootstrapScript = local.mds_bootstrap_script64
    OsVersion = local.version_split
  })
}

module "cme_iam_role" {
  source = "../cme-iam-role"
  providers = {
    aws = aws
  }
  count = local.create_iam_role ? 1 : 0

  sts_roles = var.sts_roles
  permissions = var.iam_permissions
}
