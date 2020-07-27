provider "aws" {
  region = var.region
}

module "tap" {
  source = "./modules/tap"

  region = var.region
  zone = var.zone
  
  // --- VPC Network Configuration ---
  vpc_id = var.vpc_id
  external_subnet_id = var.external_subnet_id
  internal_subnet_id = var.internal_subnet_id
  resources_tag_name = var.resources_tag_name

  // --- TAP Configuration ---
  registration_key = var.registration_key
  vxlan_id = var.vxlan_id
  schedule_scan_interval = var.schedule_scan_interval
  all_eni = var.all_eni
  blacklist_tags = var.blacklist_tags
  whitelist_tags = var.whitelist_tags
  use_whitelist = var.use_whitelist

  // --- EC2 Instance Configuration ---
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name

  // --- Check Point Settings ---
  version_license = var.version_license
}
