// --- VPC ---
resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  vpc_name   = var.vpc_name
}

// --- Public Vswitch ---
resource "alicloud_vswitch" "publicVsw" {
  for_each = var.public_vswitchs_map

  vpc_id = alicloud_vpc.vpc.id
  zone_id  = each.key
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, var.vswitchs_bit_length, each.value)
  vswitch_name  = format("Public-vswitch-%s", each.value)
  tags = {}
}

// --- Management Vswitch ---
resource "alicloud_vswitch" "managementVsw" {
  for_each = var.management_vswitchs_map

  vpc_id = alicloud_vpc.vpc.id
  zone_id  = each.key
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, var.vswitchs_bit_length, each.value)
  vswitch_name  = format("Management-vswitch-%s", each.value)
  tags = {}
}

// --- Private Vswitch ---
resource "alicloud_vswitch" "privateVsw" {
  for_each = var.private_vswitchs_map

  vpc_id = alicloud_vpc.vpc.id
  zone_id  = each.key
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, var.vswitchs_bit_length, each.value)
  vswitch_name  = format("Private-vswitch-%s", each.value)
  tags = {}
}
