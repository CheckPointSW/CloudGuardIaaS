output "management_instance_name" {
  value = module.management[0].management_instance_name
}
output "configuration_template" {
  value = var.configuration_template
}
output "controller_name" {
  value = "tgw-controller"
}
output "management_public_ip" {
  value = module.management[0].management_public_ip
}
output "management_url" {
  value = module.management[0].management_url
}
output "autoscaling_group_name" {
  value = module.autoscale.autoscale_autoscaling_group_name
}
