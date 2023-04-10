module "images" {
  source = "../modules/images"

  version_license = var.gateway_version
  chkp_type = "gateway"
}

module "common_permissive_sg" {
  source = "../modules/common/permissive_sg"

  vpc_id = var.vpc_id
  resources_tag_name = var.resources_tag_name
  gateway_name = var.gateway_name
}

module "common_gateway_instance" {
  source = "../modules/common/gateway_instance"
  security_groups = [
    module.common_permissive_sg.permissive_sg_id]
  gateway_name = var.gateway_name
  volume_size = var.volume_size
  disk_category = var.disk_category
  vswitch_id = var.public_vswitch_id
  gateway_instance_type = var.gateway_instance_type
  instance_tags = var.instance_tags
  key_name = var.key_name
  image_id = module.images.image_id
  gateway_password_hash = var.gateway_password_hash
  admin_shell = var.admin_shell
  gateway_SICKey = var.gateway_SICKey
  gateway_bootstrap_script = var.gateway_bootstrap_script
  gateway_hostname = var.gateway_hostname
  allow_upload_download = var.allow_upload_download
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
  gateway_version = var.gateway_version
}

resource "alicloud_network_interface" "internal_eni" {
  network_interface_name  = format("%s-internal-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  vswitch_id = var.private_vswitch_id
  security_group_ids  = [
    module.common_permissive_sg.permissive_sg_id]
  description = "eth1"
}

resource "alicloud_network_interface_attachment" "internal_eni_attachment" {
  instance_id          = module.common_gateway_instance.gateway_instance_id
  network_interface_id = alicloud_network_interface.internal_eni.id
}

module "common_internal_default_route" {
  source = "../modules/common/internal_default_route"

  private_route_table = var.private_route_table
  internal_eni_id = alicloud_network_interface.internal_eni.id
}

module "common_eip" {
  source = "../modules/common/elastic_ip"
  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id = module.common_gateway_instance.gateway_instance_id
}

resource "alicloud_ram_role_attachment" "attach" {
  count = var.ram_role_name != "" ? 1 : 0
  role_name    = var.ram_role_name
  instance_ids = [module.common_gateway_instance.gateway_instance_id]
}