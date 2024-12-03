output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}
output "gwlb_arn" {
  value = module.gateway_load_balancer.load_balancer_arn
}
output "gwlb_service_name" {
  value = "com.amazonaws.vpce.${data.aws_region.current.name}.${aws_vpc_endpoint_service.gwlb_endpoint_service.id}"
}
output "management_public_ip" {
  depends_on = [module.management]
  value = module.management[*].management_public_ip
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