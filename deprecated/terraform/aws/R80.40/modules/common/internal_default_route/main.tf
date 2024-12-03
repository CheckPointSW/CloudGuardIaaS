resource "aws_route" "internal_default_route" {
  count = local.internal_route_table_condition
  route_table_id = var.private_route_table
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = var.internal_eni_id
}