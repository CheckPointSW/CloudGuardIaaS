output "Deployment" {
  value = module.launch_qs_autoscale.Deployment
}

output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "public_subnets_ids_list" {
  value = module.launch_vpc.public_subnets_ids_list
}
output "private_subnets_ids_list" {
  value = module.launch_vpc.private_subnets_ids_list
}
output "public_rout_table" {
  value = module.launch_vpc.public_rtb
}

output "management_name" {
  value = module.launch_qs_autoscale.management_name
}
output "internal_port" {
  value = module.launch_qs_autoscale.internal_port
}
output "load_balancer_url" {
  value = module.launch_qs_autoscale.load_balancer_url
}
output "external_load_balancer_arn" {
  value = module.launch_qs_autoscale.external_load_balancer_arn
}
output "internal_load_balancer_arn" {
  value = module.launch_qs_autoscale.internal_load_balancer_arn
}
output "external_lb_target_group_arn" {
  value = module.launch_qs_autoscale.external_lb_target_group_arn
}
output "internal_lb_target_group_arn" {
  value = module.launch_qs_autoscale.internal_lb_target_group_arn
}

output "autoscale_autoscaling_group_name" {
  value = module.launch_qs_autoscale.autoscale_autoscaling_group_name
}
output "autoscale_autoscaling_group_arn" {
  value = module.launch_qs_autoscale.autoscale_autoscaling_group_arn
}
output "autoscale_security_group_id" {
  value = module.launch_qs_autoscale.autoscale_security_group_id
}
output "autoscale_iam_role_name" {
  value = module.launch_qs_autoscale.autoscale_iam_role_name
}

output "configuration_template" {
  value = module.launch_qs_autoscale.configuration_template
}
output "controller_name" {
  value = module.launch_qs_autoscale.controller_name
}
