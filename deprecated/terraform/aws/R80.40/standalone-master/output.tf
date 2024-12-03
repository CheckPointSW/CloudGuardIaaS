output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "internal_rtb_id" {
  value = aws_route_table.private_subnet_rtb.id
}
output "vpc_public_subnets_ids_list" {
  value = module.launch_vpc.public_subnets_ids_list
}
output "vpc_private_subnets_ids_list" {
  value = module.launch_vpc.private_subnets_ids_list
}
output "standalone_instance_id" {
  value = module.launch_standalone_into_vpc.standalone_instance_id
}
output "standalone_instance_name" {
  value = module.launch_standalone_into_vpc.standalone_instance_name
}
output "standalone_public_ip" {
  value = module.launch_standalone_into_vpc.standalone_public_ip
}
output "standalone_ssh" {
  value = module.launch_standalone_into_vpc.standalone_ssh
}
output "standalone_url" {
  value = module.launch_standalone_into_vpc.standalone_url
}