output "Deployment" {
  value = "Finalizing configuration may take up to 20 minutes after deployment is finished"
}

output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
output "vpc_public_vswitchs_ids_list" {
  value = module.launch_vpc.public_vswitchs_ids_list
}
output "image_id" {
  value = module.launch_management_into_vpc.image_id
}
output "management_instance_id" {
  value = module.launch_management_into_vpc.management_instance_id
}
output "management_instance_name" {
  value = module.launch_management_into_vpc.management_instance_name
}
output "management_instance_tags" {
  value = module.launch_management_into_vpc.management_instance_tags
}
output "management_public_ip" {
  value = module.launch_management_into_vpc.management_public_ip
}
