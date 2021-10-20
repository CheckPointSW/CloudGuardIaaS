output "Deployment" {
  value = "Finalizing configuration may take up to 20 minutes after deployment is finished"
}

output "image_id" {
  value = module.images.image_id
}
output "management_instance_id" {
  value = alicloud_instance.management_instance.id
}
output "management_instance_name" {
  value = alicloud_instance.management_instance.tags["Name"]
}
output "management_instance_tags" {
  value = alicloud_instance.management_instance.tags
}
output "management_public_ip" {
  value = module.common_eip.instance_eip_public_ip
}