output "instance_eip_id" {
  value = alicloud_eip.instance_eip.*.id
}
output "instance_eip_public_ip" {
  value = alicloud_eip.instance_eip.*.ip_address
}

