provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "amis" {
  source = "../modules/amis"

  version_license = var.management_version
  chkp_type = "management"
}

resource "aws_security_group" "management_sg" {
  description = "terraform Management security group"
  vpc_id = var.vpc_id
  name_prefix = format("%s_SecurityGroup", var.management_name)
  // Group name
  tags = {
    Name = format("%s_SecurityGroup", var.management_name)
    // Resource name
  }
  ingress {
    from_port = 257
    to_port = 257
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

resource "aws_network_interface" "external-eni" {
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.management_sg.id]
  description = "eth0"
  source_dest_check = true
  tags = {
    Name = format("%s-network_interface", var.management_name)
  }
}

resource "aws_eip" "eip" {
  count = var.allocate_and_associate_eip ? 1 : 0
  network_interface = aws_network_interface.external-eni.id
}

resource "aws_iam_instance_profile" "management_instance_profile" {
  count = local.pre_role
  path = "/"
  role = var.predefined_role
}

resource "aws_launch_template" "management_launch_template" {
  depends_on = [
    aws_network_interface.external-eni,
    aws_eip.eip
  ]

  instance_type = var.management_instance_type
  key_name = var.key_name
  image_id = module.amis.ami_id
  description = "Initial launch template version"

  iam_instance_profile {
    name = local.use_role == 1 ? (local.pre_role == 1 ? aws_iam_instance_profile.management_instance_profile[0].id : join("", (var.is_gwlb_iam == true ? module.cme_iam_role_gwlb.*.cme_iam_profile_name : module.cme_iam_role.*.cme_iam_profile_name))): ""
  }

  metadata_options {
    http_tokens = var.metadata_imdsv2_required ? "required" : "optional"
  }

  network_interfaces {
    network_interface_id = aws_network_interface.external-eni.id
    device_index = 0
  }
}

resource "aws_instance" "management-instance" {
  depends_on = [
    aws_launch_template.management_launch_template
  ]

  launch_template {
    id = aws_launch_template.management_launch_template.id
    version = "$Latest"
  }

  disable_api_termination = var.disable_instance_termination

  tags = merge({
    Name = var.management_name
  }, var.instance_tags)

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted = local.volume_encryption_condition
    kms_key_id = local.volume_encryption_condition ? var.volume_encryption : ""
  }

  lifecycle {
    ignore_changes = [ebs_block_device,]
  }

  user_data = templatefile("${path.module}/management_userdata.yaml", {
    // script's arguments
    Hostname = var.management_hostname,
    PasswordHash = local.management_password_hash_base64,
    MaintenanceModePassword = local.maintenance_mode_password_hash_base64,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp
    NTPSecondary = var.secondary_ntp
    Shell = var.admin_shell,
    AdminSubnet = var.admin_cidr
    ManagementInstallationType = var.management_installation_type
    SICKey = local.management_SICkey_base64,
    OsVersion = local.version_split
    EnableInstanceConnect = var.enable_instance_connect
    AllocateElasticIP = var.allocate_and_associate_eip
    GatewayManagement = var.gateway_management
    BootstrapScript = local.management_bootstrap_script64
    PubMgmt = local.pub_mgmt

  })
}

module "cme_iam_role" {
  source = "../cme-iam-role"
  providers = {
    aws = aws
  }
  count = local.new_instance_profile_general

  sts_roles = var.sts_roles
  permissions = var.iam_permissions
}

module "cme_iam_role_gwlb" {
  source = "../cme-iam-role-gwlb"
  providers = {
    aws = aws
  }
  count = local.new_instance_profile_gwlb

  sts_roles = var.sts_roles
  permissions = var.iam_permissions
}
