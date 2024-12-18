provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

// --- VPC ---
module "launch_vpc" {
  source = "../modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnets_map = var.public_subnets_map
  private_subnets_map = {}
  subnets_bit_length = var.subnets_bit_length
}

module "launch_tgw_asg_into_vpc" {
  source = "../tgw-asg"
  providers = {
    aws = aws
  }

  vpc_id = module.launch_vpc.vpc_id
  gateways_subnets = module.launch_vpc.public_subnets_ids_list
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  allow_upload_download = var.allow_upload_download
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  gateways_min_group_size = var.gateways_min_group_size
  gateways_max_group_size = var.gateways_max_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  enable_cloudwatch = var.enable_cloudwatch
  asn = var.asn
  management_deploy = var.management_deploy
  management_instance_type = var.management_instance_type
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  management_permissions = var.management_permissions
  management_predefined_role = var.management_predefined_role
  gateways_blades = var.gateways_blades
  admin_cidr = var.admin_cidr
  gateways_addresses = var.gateways_addresses
  gateway_management = var.gateway_management
  control_gateway_over_public_or_private_address = var.control_gateway_over_public_or_private_address
  management_server = var.management_server
  configuration_template = var.configuration_template
}
