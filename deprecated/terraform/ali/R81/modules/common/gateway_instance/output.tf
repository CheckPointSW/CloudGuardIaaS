output "gateway_instance_id" {
  value = alicloud_instance.gateway_instance.id
}
output "gateway_instance_name" {
  value = alicloud_instance.gateway_instance.tags["Name"]
}
