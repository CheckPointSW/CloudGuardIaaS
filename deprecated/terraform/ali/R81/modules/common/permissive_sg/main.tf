resource "alicloud_security_group" "permissive_sg" {
  name = format("%s-PermissiveSecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name)
  description = "Permissive security group"
  vpc_id = var.vpc_id
}

resource "alicloud_security_group_rule" "permissive_egress" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "permissive_ingress" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.permissive_sg.id
  cidr_ip           = "0.0.0.0/0"
}