provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


module "cluster_into_vpc" {
  source = "../cross-az-cluster"
  providers = {
    aws = aws
  }

  vpc_id = var.vpc_id
  public_subnet_ids = tolist([var.public_subnet_1, var.public_subnet_2])
  private_subnet_ids = tolist([var.private_subnet_1, var.private_subnet_2])
  private_route_table = var.private_route_table
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  volume_size = var.volume_size
  volume_encryption = var.volume_encryption
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  instance_tags = var.instance_tags
  predefined_role = var.predefined_role
  gateway_version = var.gateway_version
  admin_shell = var.admin_shell
  gateway_SICKey = var.gateway_SICKey
  gateway_password_hash = var.gateway_password_hash
  resources_tag_name = var.resources_tag_name
  gateway_hostname = var.gateway_hostname
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
  volume_type = var.volume_type
}
resource "aws_route_table" "tgw_route_table" {
  vpc_id = var.vpc_id
  route{
    cidr_block = "0.0.0.0/0"
    network_interface_id = module.cluster_into_vpc.member_a_eni
  }
  tags = {
    Name = "TGW Attachment Route Table"
    Network = "Private"
  }
}
resource "aws_route_table_association" "tgw_attachment1_rtb_assoc" {
  subnet_id      = var.tgw_subnet_1_id
  route_table_id = aws_route_table.tgw_route_table.id
}
resource "aws_route_table_association" "tgw_attachment2_rtb_assoc" {
  subnet_id      = var.tgw_subnet_2_id
  route_table_id = aws_route_table.tgw_route_table.id
}