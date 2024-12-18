output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "public_subnets_ids_list" {
  value = module.launch_vpc.public_subnets_ids_list
}
output "management_instance_name" {
  value = module.launch_tgw_asg_into_vpc.management_instance_name
}
output "configuration_template" {
  value = module.launch_tgw_asg_into_vpc.configuration_template
}
output "controller_name" {
  value = module.launch_tgw_asg_into_vpc.controller_name
}
output "management_public_ip" {
  value = module.launch_tgw_asg_into_vpc.management_public_ip
}
output "management_url" {
  value = module.launch_tgw_asg_into_vpc.management_url
}
output "autoscaling_group_name" {
  value = module.launch_tgw_asg_into_vpc.autoscaling_group_name
}
