output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "internal_rt_id" {
  value = alicloud_route_table.private_vswitch_rt.id
}
output "vpc_cluster_vswitchs_ids_list" {
  value = module.launch_vpc.public_vswitchs_ids_list
}
output "vpc_management_vswitchs_ids_list" {
  value = module.launch_vpc.management_vswitchs_ids_list
}
output "vpc_private_vswitchs_ids_list" {
  value = module.launch_vpc.private_vswitchs_ids_list
}
output "image_id" {
  value = module.launch_cluster_into_vpc.image_id
}
output "cluster_primary_EIP" {
  value = module.launch_cluster_into_vpc.cluster_primary_EIP
}
output "cluster_secondary_EIP" {
  value = module.launch_cluster_into_vpc.cluster_secondary_EIP
}
output "member_a_EIP" {
  value = module.launch_cluster_into_vpc.member_a_EIP
}
output "member_b_EIP" {
  value = module.launch_cluster_into_vpc.member_b_EIP
}
output "member_a_instance_id" {
  value = module.launch_cluster_into_vpc.member_a_instance_id
}
output "member_b_instance_id" {
  value = module.launch_cluster_into_vpc.member_b_instance_id
}
output "member_a_instance_name" {
  value = module.launch_cluster_into_vpc.member_a_instance_name
}
output "member_b_instance_name" {
  value = module.launch_cluster_into_vpc.member_b_instance_name
}
output "permissive_sg_id" {
  value = module.launch_cluster_into_vpc.permissive_sg_id
}
output "permissive_sg_name" {
  value = module.launch_cluster_into_vpc.permissive_sg_name
}