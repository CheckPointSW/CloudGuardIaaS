output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}

output "autoscale-autoscaling_group_id" {
  value = aws_autoscaling_group.asg.id
}
output "autoscale-autoscaling_group_name" {
  value = aws_autoscaling_group.asg.name
}
output "autoscale-autoscaling_group_arn" {
  value = aws_autoscaling_group.asg.arn
}
output "autoscale-autoscaling_group_availability_zones" {
  value = aws_autoscaling_group.asg.availability_zones
}
output "autoscale-autoscaling_group_desired_capacity" {
  value = aws_autoscaling_group.asg.desired_capacity
}
output "autoscale-autoscaling_group_min_size" {
  value = aws_autoscaling_group.asg.min_size
}
output "autoscale-autoscaling_group_max_size" {
  value = aws_autoscaling_group.asg.max_size
}
output "autoscale-autoscaling_group_load_balancers" {
  value = aws_autoscaling_group.asg.load_balancers
}
output "autoscale-autoscaling_group_target_group_arns" {
  value = aws_autoscaling_group.asg.target_group_arns
}
output "autoscale-autoscaling_group_subnets" {
  value = aws_autoscaling_group.asg.vpc_zone_identifier
}

output "autoscale-launch_configuration_id" {
  value = aws_launch_configuration.asg_launch_configuration.id
}

output "autoscale-security_group" {
  value = aws_security_group.permissive_sg.id
}

output "autoscale-iam_role_name" {
  value = aws_iam_role.role.*.name
}

