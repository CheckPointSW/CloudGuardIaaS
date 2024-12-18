output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}
output "management_public_ip" {
  depends_on = [module.tgw-gwlb]
  value = module.tgw-gwlb[*].management_public_ip
}
output "gwlb_arn" {
  depends_on = [module.tgw-gwlb]
  value = module.tgw-gwlb[*].gwlb_arn
}
output "gwlb_service_name" {
  depends_on = [module.tgw-gwlb]
  value = module.tgw-gwlb[*].gwlb_service_name
}
output "gwlb_name" {
  value = var.gateway_load_balancer_name
}
output "controller_name" {
  value = "gwlb-controller"
}
output "template_name" {
  value = var.configuration_template
}