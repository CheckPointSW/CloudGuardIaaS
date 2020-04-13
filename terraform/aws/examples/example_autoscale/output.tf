
output "autoscale_output" {
  value = module.autoscale
}

output "autoscale-autoscaling_group_arn" {
  value = module.autoscale.autoscale-autoscaling_group_arn
}

output "autoscale-autoscaling_group_id" {
  value = module.autoscale.autoscale-autoscaling_group_id
}

output "autoscale-autoscaling_group_name" {
  value = module.autoscale.autoscale-autoscaling_group_name
}

output "autoscale-launch_configuration_id" {
  value = module.autoscale.autoscale-launch_configuration_id
}

output "autoscale-security_group" {
  value = module.autoscale.autoscale-security_group
}

output "autoscale-iam_role_name" {
  value = module.autoscale.autoscale-iam_role_name
}

output "autoscale-autoscaling_group_subnets" {
  value = module.autoscale.autoscale-autoscaling_group_subnets
}

output "autoscale-autoscaling_group_availability_zones" {
  value = module.autoscale.autoscale-autoscaling_group_availability_zones
}

output "autoscale-autoscaling_group_max_size" {
  value = module.autoscale.autoscale-autoscaling_group_max_size
}

output "autoscale-autoscaling_group_min_size" {
  value = module.autoscale.autoscale-autoscaling_group_min_size
}

output "autoscale-autoscaling_group_desired_capacity" {
  value = module.autoscale.autoscale-autoscaling_group_desired_capacity
}

output "autoscale-autoscaling_group_load_balancers" {
  value = module.autoscale.autoscale-autoscaling_group_load_balancers
}

output "autoscale-autoscaling_group_target_group_arns" {
  value = module.autoscale.autoscale-autoscaling_group_target_group_arns
}

data "aws_instances" "asg_instances" {
  filter {
    name = "tag:aws:autoscaling:groupName"
    values = [module.autoscale.autoscale-autoscaling_group_name]
  }
}

output "autoscale_instances" {
  value = data.aws_instances.asg_instances
}
