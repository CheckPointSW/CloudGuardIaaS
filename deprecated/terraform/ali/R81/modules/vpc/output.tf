output "vpc_id" {
  value = alicloud_vpc.vpc.id
}
output "vpc_name" {
  value = alicloud_vpc.vpc.name
}
output "public_vswitchs_ids_list" {
  value = [for public_vswitch in alicloud_vswitch.publicVsw : public_vswitch.id ]
}
output "management_vswitchs_ids_list" {
  value = [for management_vswitch in alicloud_vswitch.managementVsw : management_vswitch.id ]
}
output "private_vswitchs_ids_list" {
  value = [for private_vswitch in alicloud_vswitch.privateVsw : private_vswitch.id]
}
