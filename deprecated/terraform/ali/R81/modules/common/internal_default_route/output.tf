output "internal_default_route_id" {
  value = alicloud_route_entry.internal_default_route.*.id
}