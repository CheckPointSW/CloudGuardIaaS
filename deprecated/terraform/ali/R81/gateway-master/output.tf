output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "internal_rt_id" {
  value = alicloud_route_table.private_vswitch_rt.id
}
output "vpc_public_vswitchs_ids_list" {
  value = module.launch_vpc.public_vswitchs_ids_list
}
output "vpc_private_vswitchs_ids_list" {
  value = module.launch_vpc.private_vswitchs_ids_list
}
output "image_id" {
  value = module.launch_gateway_into_vpc.image_id
}
output "permissive_sg_id" {
  value = module.launch_gateway_into_vpc.permissive_sg_id
}
output "permissive_sg_name" {
  value = module.launch_gateway_into_vpc.permissive_sg_name
}
output "gateway_eip_id" {
  value = module.launch_gateway_into_vpc.gateway_eip_id
}
output "gateway_eip_public_ip" {
  value = module.launch_gateway_into_vpc.gateway_eip_public_ip
}
output "gateway_instance_id" {
  value = module.launch_gateway_into_vpc.gateway_instance_id
}
output "gateway_instance_name" {
  value = module.launch_gateway_into_vpc.gateway_instance_name
}