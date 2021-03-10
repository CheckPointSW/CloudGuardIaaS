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

resource "aws_instance" "standalone-instance" {
  network_interface {
    network_interface_id = aws_network_interface.public_eni.id
    device_index = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.private_eni.id
    device_index = 1
  }

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
  instance_type = var.standalone_instance_type
  key_name = var.key_name

  ami = module.amis.ami_id
  user_data = templatefile("${path.module}/standalone_user_data.sh", {
    // script's arguments
    Hostname = var.standalone_hostname,
    PasswordHash = var.standalone_password_hash,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    AdminSubnet = var.admin_cidr,
    EnableInstanceConnect = var.enable_instance_connect,
    StandaloneBootstrapScript = var.standalone_bootstrap_script
  })
}