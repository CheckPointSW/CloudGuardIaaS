// --- VPC ---
module "launch_vpc" {
  source = "../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  public_vswitchs_map = var.public_vswitchs_map
  private_vswitchs_map = {}
  vswitchs_bit_length = var.vswitchs_bit_length
}

module "launch_management_into_vpc" {
  source = "../management"

  vpc_id = module.launch_vpc.vpc_id
  vswitch_id = module.launch_vpc.public_vswitchs_ids_list[0]
  ram_role_name = var.ram_role_name

  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name = var.key_name

  allocate_and_associate_eip = var.allocate_and_associate_eip
  volume_size = var.volume_size
  disk_category = var.disk_category
  instance_tags = var.instance_tags
  version_license = var.version_license
  admin_shell = var.admin_shell
  password_hash = var.password_hash
  hostname = var.hostname
  is_primary_management = var.is_primary_management
  SICKey = var.SICKey
  allow_upload_download = var.allow_upload_download
  gateway_management = var.gateway_management
  admin_cidr = var.admin_cidr
  gateway_addresses = var.gateway_addresses
  bootstrap_script = var.bootstrap_script
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
}
