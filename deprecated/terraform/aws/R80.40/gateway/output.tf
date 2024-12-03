output "ami_id" {
  value = module.amis.ami_id
}
output "permissive_sg_id" {
  value = module.common_permissive_sg.permissive_sg_id
}
output "permissive_sg_name" {
  value = module.common_permissive_sg.permissive_sg_name
}
output "gateway_url" {
  value = format("https://%s", module.common_eip.gateway_eip_public_ip[0])
}
output "gateway_public_ip" {
  value = module.common_eip.gateway_eip_public_ip
}
output "gateway_instance_id" {
  value = module.common_gateway_instance.gateway_instance_id
}
output "gateway_instance_name" {
  value = module.common_gateway_instance.gateway_instance_name
}