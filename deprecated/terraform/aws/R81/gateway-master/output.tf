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
output "ami_id" {
  value = module.launch_gateway_into_vpc.ami_id
}
output "permissive_sg_id" {
  value = module.launch_gateway_into_vpc.permissive_sg_id
}
output "permissive_sg_name" {
  value = module.launch_gateway_into_vpc.permissive_sg_name
}
output "gateway_url" {
  value = module.launch_gateway_into_vpc.gateway_url
}
output "gateway_public_ip" {
  value = module.launch_gateway_into_vpc.gateway_public_ip
}
output "gateway_instance_id" {
  value = module.launch_gateway_into_vpc.gateway_instance_id
}
output "gateway_instance_name" {
  value = module.launch_gateway_into_vpc.gateway_instance_name
}