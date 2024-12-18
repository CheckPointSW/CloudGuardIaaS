locals {
  internal_route_table_condition = var.private_route_table != "" ? 1 : 0
}