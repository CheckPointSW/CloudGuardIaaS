provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

module "amis" {
  source = "../modules/amis"

  version_license = var.gateway_version
  chkp_type = "gateway"
}

module "common_permissive_sg" {
  source = "../modules/common/permissive_sg"

  vpc_id = var.vpc_id
  resources_tag_name = var.resources_tag_name
  gateway_name = var.gateway_name
}

resource "aws_network_interface" "public_eni" {
  subnet_id = var.public_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "eth0"
  source_dest_check = false
  tags = {
    Name = format("%s-external-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}
resource "aws_network_interface" "private_eni" {
  subnet_id = var.private_subnet_id
  security_groups = [module.common_permissive_sg.permissive_sg_id]
  description = "eth1"
  source_dest_check = false
  tags = {
    Name = format("%s-internal-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) }
}

module "common_eip" {
  source = "../modules/common/elastic_ip"
  depends_on = [
    module.common_gateway_instance
  ]

  allocate_and_associate_eip = var.allocate_and_associate_eip
  external_eni_id = aws_network_interface.public_eni.id
  private_ip_address = aws_network_interface.public_eni.private_ip
}

module "common_internal_default_route" {
  source = "../modules/common/internal_default_route"

  private_route_table = var.private_route_table
  internal_eni_id = aws_network_interface.private_eni.id
}

module "common_gateway_instance" {
  source = "../modules/common/gateway_instance"

  external_eni_id = aws_network_interface.public_eni.id
  internal_eni_id = aws_network_interface.private_eni.id
  gateway_name = var.gateway_name
  management_server = var.management_server
  configuration_template = var.configuration_template
  control_gateway_over_public_or_private_address = var.control_gateway_over_public_or_private_address
  volume_size = var.volume_size
  volume_encryption = var.volume_encryption
  gateway_version = module.amis.version_license_with_suffix
  gateway_instance_type = var.gateway_instance_type
  instance_tags = var.instance_tags
  key_name = var.key_name
  ami_id = module.amis.ami_id
  gateway_password_hash = var.gateway_password_hash
  admin_shell = var.admin_shell
  gateway_SICKey = var.gateway_SICKey
  gateway_bootstrap_script = var.gateway_bootstrap_script
  gateway_hostname = var.gateway_hostname
  allow_upload_download = var.allow_upload_download
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
  enable_instance_connect = var.enable_instance_connect
}