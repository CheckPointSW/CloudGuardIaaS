provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


module "launch_vpc" {
  source = "../modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnets_map = var.public_subnets_map
  private_subnets_map = {}
  subnets_bit_length = var.subnets_bit_length
}

module "gwlb" {
  source = "../gwlb"
  providers = {
    aws = aws
  }
  vpc_id = module.launch_vpc.vpc_id
  subnet_ids = module.launch_vpc.public_subnets_ids_list

  // --- General Settings ---
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  volume_size = var.volume_size
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination  = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  allow_upload_download = var.allow_upload_download
  management_server = var.management_server
  configuration_template = var.configuration_template
  admin_shell = var.admin_shell

  // --- Gateway Load Balancer Configuration ---
  gateway_load_balancer_name = var.gateway_load_balancer_name
  target_group_name = var.target_group_name
  connection_acceptance_required = false
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  // --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  gateways_provision_address_type = var.gateways_provision_address_type
  allocate_public_IP = var.allocate_public_IP
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script

  // --- Check Point CloudGuard IaaS Security Management Server Configuration ---
  management_deploy = var.management_deploy
  management_instance_type = var.management_instance_type
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  gateways_policy = var.gateways_policy
  gateway_management = var.gateway_management
  admin_cidr = var.admin_cidr
  gateways_addresses = var.gateways_addresses

  volume_type = var.volume_type
}