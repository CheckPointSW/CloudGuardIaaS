output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}

output "management_name" {
  value = "${var.provision_tag}-management"
}
output "internal_port" {
  value = local.encrypted_protocol_condition ? 443 : 80
}
output "load_balancer_url" {
  value = module.external_load_balancer.load_balancer_url
}
output "external_load_balancer_arn" {
  value = module.external_load_balancer.load_balancer_arn
}
output "internal_load_balancer_arn" {
  value = module.internal_load_balancer[*].load_balancer_arn
}
output "external_lb_target_group_arn" {
  value = module.external_load_balancer.target_group_arn
}
output "internal_lb_target_group_arn" {
  value = module.internal_load_balancer[*].target_group_arn
}

output "autoscale_autoscaling_group_name" {
  value = module.autoscale.autoscale_autoscaling_group_name
}
output "autoscale_autoscaling_group_arn" {
  value = module.autoscale.autoscale_autoscaling_group_arn
}
output "autoscale_security_group_id" {
  value = module.autoscale.autoscale_security_group_id
}
output "autoscale_iam_role_name" {
  value = module.autoscale.autoscale_iam_role_name
}

output "configuration_template" {
  value = "${var.provision_tag}-template"
}
output "controller_name" {
  value = "${var.provision_tag}-controller"
}
