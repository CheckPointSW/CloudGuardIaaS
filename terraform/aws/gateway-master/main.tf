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
  private_subnets_map = var.private_subnets_map
  subnets_bit_length = var.subnets_bit_length
}

resource "aws_route_table" "private_subnet_rtb" {
  depends_on = [module.launch_vpc]
  vpc_id = module.launch_vpc.vpc_id
  tags = {
    Name = "Private Subnets Route Table"
  }
}
resource "aws_route_table_association" "private_rtb_to_private_subnets" {
  depends_on = [module.launch_vpc, aws_route_table.private_subnet_rtb]
  route_table_id = aws_route_table.private_subnet_rtb.id
  subnet_id = module.launch_vpc.private_subnets_ids_list[0]
}

module "launch_gateway_into_vpc" {
  source = "../gateway"
  providers = {
    aws = aws
  }

  vpc_id = module.launch_vpc.vpc_id
  public_subnet_id = module.launch_vpc.public_subnets_ids_list[0]
  private_subnet_id = module.launch_vpc.private_subnets_ids_list[0]
  private_route_table = aws_route_table.private_subnet_rtb.id
  resources_tag_name = var.resources_tag_name
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  allocate_and_associate_eip = var.allocate_and_associate_eip
  volume_size = var.volume_size
  volume_encryption = var.volume_encryption
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  instance_tags = var.instance_tags
  gateway_version = var.gateway_version
  admin_shell = var.admin_shell
  gateway_SICKey = var.gateway_SICKey
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_TokenKey = var.gateway_TokenKey
  gateway_hostname = var.gateway_hostname
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
  control_gateway_over_public_or_private_address = var.control_gateway_over_public_or_private_address
  management_server = var.management_server
  configuration_template = var.configuration_template
}
