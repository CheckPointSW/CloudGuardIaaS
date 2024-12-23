resource "alicloud_route_entry" "internal_default_route" {
  count = local.internal_route_table_condition
  route_table_id = var.private_route_table
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type = "NetworkInterface"
  nexthop_id = var.internal_eni_id
}