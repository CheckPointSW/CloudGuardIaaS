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

// Instances
resource "alicloud_instance" "member-a-instance" {
  instance_name = format("%s-Member-A", var.gateway_name)
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  image_id = module.images.image_id
  vswitch_id = var.cluster_vswitch_id
  security_groups = [
    module.common_permissive_sg.permissive_sg_id]
  system_disk_size = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = format("%s-Member-A", var.gateway_name)
  }, var.instance_tags)

  user_data = templatefile("${path.module}/cluster_member_user_data.sh", {
    // script's arguments
    Hostname = format("%s-member-a", var.gateway_hostname),
    PasswordHash = var.gateway_password_hash,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    GatewayBootstrapScript = var.gateway_bootstrap_script,
    SICKey = var.gateway_SICKey,
    ManagementIpAddress = var.management_ip_address,
    cluster_new_config = local.cluster_new_config
  })
}
resource "alicloud_instance" "member-b-instance" {
  instance_name = format("%s-Member-B", var.gateway_name)
  instance_type = var.gateway_instance_type
  key_name = var.key_name
  image_id = module.images.image_id
  vswitch_id = var.cluster_vswitch_id
  security_groups = [
    module.common_permissive_sg.permissive_sg_id]
  system_disk_size = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = format("%s-Member-B", var.gateway_name)
  }, var.instance_tags)

  user_data = templatefile("${path.module}/cluster_member_user_data.sh", {
    // script's arguments
    Hostname = format("%s-member-b", var.gateway_hostname),
    PasswordHash = var.gateway_password_hash,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp,
    NTPSecondary = var.secondary_ntp,
    Shell = var.admin_shell,
    GatewayBootstrapScript = var.gateway_bootstrap_script,
    SICKey = var.gateway_SICKey,
    ManagementIpAddress = var.management_ip_address,
    cluster_new_config = local.cluster_new_config
  })
}

// Management ENIs
resource "alicloud_network_interface" "member_a_mgmt_eni" {
  network_interface_name  = format("%s-Member-A-management-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  vswitch_id = var.mgmt_vswitch_id
  security_group_ids  = [
    module.common_permissive_sg.permissive_sg_id]
  description = "eth2"
}
resource "alicloud_network_interface_attachment" "member_a_mgmt_eni_attachment" {
  instance_id = alicloud_instance.member-a-instance.id
  network_interface_id = alicloud_network_interface.member_a_mgmt_eni.id
}
resource "alicloud_network_interface" "member_b_mgmt_eni" {
  network_interface_name  = format("%s-Member-B-management-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  vswitch_id = var.mgmt_vswitch_id
  security_group_ids  = [
    module.common_permissive_sg.permissive_sg_id]
  description = "eth2"
}
resource "alicloud_network_interface_attachment" "member_b_mgmt_eni_attachment" {
  instance_id = alicloud_instance.member-b-instance.id
  network_interface_id = alicloud_network_interface.member_b_mgmt_eni.id
}

// Internal ENIs
resource "alicloud_network_interface" "member_a_internal_eni" {
  depends_on = [alicloud_network_interface_attachment.member_a_mgmt_eni_attachment]
  network_interface_name  = format("%s-Member-A-internal-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  vswitch_id = var.private_vswitch_id
  security_group_ids  = [
    module.common_permissive_sg.permissive_sg_id]
  description = "eth2"
}
resource "alicloud_network_interface_attachment" "member_a_internal_eni_attachment" {
  instance_id = alicloud_instance.member-a-instance.id
  network_interface_id = alicloud_network_interface.member_a_internal_eni.id
}
resource "alicloud_network_interface" "member_b_internal_eni" {
  depends_on = [alicloud_network_interface_attachment.member_b_mgmt_eni_attachment]
  network_interface_name  = format("%s-Member-B-internal-eni", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  vswitch_id = var.private_vswitch_id
  security_group_ids  = [
    module.common_permissive_sg.permissive_sg_id]
  description = "eth2"
}
resource "alicloud_network_interface_attachment" "member_b_internal_eni_attachment" {
  instance_id = alicloud_instance.member-b-instance.id
  network_interface_id = alicloud_network_interface.member_b_internal_eni.id
}

// EIPs
module "common_cluster_primary_eip" {
  source = "../modules/common/elastic_ip"

  allocate_and_associate_eip = true
  instance_id = alicloud_instance.member-a-instance.id
  eip_name = format("%s-cluster-primary-eip", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
}
module "common_cluster_secondary_eip" {
  source = "../modules/common/elastic_ip"

  allocate_and_associate_eip = true
  instance_id = alicloud_instance.member-b-instance.id
  eip_name = format("%s-cluster-secondary-eip", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
}
module "common_member_a_mgmt_eip" {
  source = "../modules/common/elastic_ip"

  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id = alicloud_network_interface.member_a_mgmt_eni.id
  association_instance_type = "NetworkInterface"
  eip_name = format("%s-member-A-eip", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
}
module "common_member_b_mgmt_eip" {
  source = "../modules/common/elastic_ip"

  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id = alicloud_network_interface.member_b_mgmt_eni.id
  association_instance_type = "NetworkInterface"
  eip_name = format("%s-member-B-eip", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
}

module "common_internal_default_route" {
  source = "../modules/common/internal_default_route"

  private_route_table = var.private_route_table
  internal_eni_id = alicloud_network_interface.member_a_internal_eni.id
}

module "cluster_ram_role" {
  count = local.create_ram_role
  source = "../modules/cluster-ram-role"

  gateway_name = var.gateway_name
}

resource "alicloud_ram_role_attachment" "attach" {
  depends_on = [alicloud_instance.member-a-instance, alicloud_instance.member-b-instance]
  role_name = var.ram_role_name != "" ? var.ram_role_name : module.cluster_ram_role[0].cluster_ram_role_name
  instance_ids = [alicloud_instance.member-a-instance.id, alicloud_instance.member-b-instance.id]
}
