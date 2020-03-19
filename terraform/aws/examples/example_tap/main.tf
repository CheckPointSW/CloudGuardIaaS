provider "aws" {
  region = var.region
}

module "tap" {
  source = "../../modules/tap"

  // --- VPC Network Configuration ---
  vpc_id = var.vpc_id
  external_subnet_id = var.external_subnet_id
  internal_subnet_id = var.internal_subnet_id
  resources_tag_name = var.resources_tag_name

  // --- TAP Configuration ---
  registration_key = var.registration_key
  vxlan_ids = var.vxlan_ids
  blacklist_tags = var.blacklist_tags
  schedule_scan_period = var.schedule_scan_period

  // --- EC2 Instance Configuration ---
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name = var.key_name
  password_hash = var.password_hash
  is_allocate_and_associate_elastic_ip = var.is_allocate_and_associate_elastic_ip
  is_enable_instance_connect = var.is_enable_instance_connect

  // --- Check Point Settings ---
  version_license = var.version_license
}
