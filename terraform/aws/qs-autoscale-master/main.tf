provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

module "launch_vpc" {
  source = "../modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnets_map = var.public_subnets_map
  private_subnets_map = var.private_subnets_map
  subnets_bit_length = var.subnets_bit_length
}

module "launch_qs_autoscale" {
  source = "../qs-autoscale"
  providers = {
    aws = aws
  }

  region = var.region
  prefix = var.prefix
  asg_name = var.asg_name
  vpc_id = module.launch_vpc.vpc_id
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  allow_upload_download = var.allow_upload_download
  provision_tag = var.provision_tag
  load_balancers_type = var.load_balancers_type
  load_balancer_protocol = var.load_balancer_protocol
  certificate = var.certificate
  service_port = var.service_port
  gateways_subnets = module.launch_vpc.public_subnets_ids_list
  gateway_instance_type = var.gateway_instance_type
  gateways_min_group_size = var.gateways_min_group_size
  gateways_max_group_size = var.gateways_max_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_SICKey = var.gateway_SICKey
  enable_cloudwatch = var.enable_cloudwatch
  management_deploy = var.management_deploy
  management_instance_type = var.management_instance_type
  management_version = var.management_version
  management_password_hash = var.gateway_password_hash
  gateways_policy = var.gateways_policy
  gateways_blades = var.gateways_blades
  admin_cidr = var.admin_cidr
  gateways_addresses = var.gateways_addresses
  servers_deploy= var.servers_deploy
  servers_subnets = module.launch_vpc.private_subnets_ids_list
  servers_instance_type = var.servers_instance_type
  server_ami = var.server_ami
}