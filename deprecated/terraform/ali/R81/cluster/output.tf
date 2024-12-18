output "cluster_primary_EIP" {
  value = module.common_cluster_primary_eip.instance_eip_public_ip[0]
}
output "cluster_secondary_EIP" {
  value = module.common_cluster_secondary_eip.instance_eip_public_ip[0]
}
output "image_id" {
  value = module.images.image_id
}
output "member_a_EIP" {
  value = module.common_member_a_mgmt_eip.instance_eip_public_ip[0]
}
output "member_b_EIP" {
  value = module.common_member_b_mgmt_eip.instance_eip_public_ip[0]
}
output "member_a_instance_id" {
  value = alicloud_instance.member-a-instance.id
}
output "member_b_instance_id" {
  value = alicloud_instance.member-b-instance.id
}
output "member_a_instance_name" {
  value = alicloud_instance.member-a-instance.instance_name
}
output "member_b_instance_name" {
  value = alicloud_instance.member-b-instance.instance_name
}
output "permissive_sg_id" {
  value = module.common_permissive_sg.permissive_sg_id
}
output "permissive_sg_name" {
  value = module.common_permissive_sg.permissive_sg_name
}