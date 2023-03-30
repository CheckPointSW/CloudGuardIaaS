module "images" {
  source = "../modules/images"

  version_license = var.version_license
  chkp_type = "management"
}

resource "alicloud_security_group" "management_sg" {
  name = format("%s-SecurityGroup", var.instance_name)
  description = "TF Management security group"
  vpc_id = var.vpc_id
}

resource "alicloud_security_group_rule" "permissive_egress" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "management_ingress-257" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "257/257"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-8211" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8211/8211"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-18191-2" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18191/18192"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-18210-11" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18210/18211"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-18221" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18221/18221"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-18264" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18264/18264"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.gateway_addresses
}

resource "alicloud_security_group_rule" "management_ingress-22" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress-433" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "433/433"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress-18190" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "18190/18190"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_security_group_rule" "management_ingress-19009" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "19009/19009"
  priority          = 1
  security_group_id = alicloud_security_group.management_sg.id
  cidr_ip           = var.admin_cidr
}

resource "alicloud_instance" "management_instance" {
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name = var.key_name
  image_id = module.images.image_id
  vswitch_id = var.vswitch_id
  security_groups = [alicloud_security_group.management_sg.id]
  system_disk_size = var.volume_size
  system_disk_category = var.disk_category

  tags = merge({
    Name = var.instance_name
  }, var.instance_tags)

  user_data = templatefile("${path.module}/mgmt_user_data.sh", {
    // script's arguments
    Hostname = var.hostname,
    PasswordHash = var.password_hash,
    AllowUploadDownload = var.allow_upload_download,
    NTPPrimary = var.primary_ntp
    NTPSecondary = var.secondary_ntp
    Shell = var.admin_shell,
    AdminCidr = var.admin_cidr
    IsPrimary = var.is_primary_management
    SICKey = var.SICKey,
    AllocateElasticIP = var.allocate_and_associate_eip,
    GatewayManagement = var.gateway_management,
    BootstrapScript = var.bootstrap_script,
    mgmt_new_config = local.mgmt_new_config
  })
}

module "common_eip" {
  source = "../modules/common/elastic_ip"
  allocate_and_associate_eip = var.allocate_and_associate_eip
  instance_id = alicloud_instance.management_instance.id
}

resource "alicloud_ram_role_attachment" "attach" {
  count = var.ram_role_name != "" ? 1 : 0
  role_name    = var.ram_role_name
  instance_ids = alicloud_instance.management_instance.*.id
}