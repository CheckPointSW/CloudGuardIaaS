output "SIC_key" {
  value = random_string.random_sic_key.result
}
output "management_name" {
  value = var.management_name
}
output "configuration_template_name" {
  value = var.configuration_template_name
}
output "instance_template_name" {
  value = google_compute_instance_template.instance_template.name
}
output "instance_group_manager_name" {
  value = google_compute_region_instance_group_manager.instance_group_manager.name
}
output "autoscaler_name" {
  value = google_compute_region_autoscaler.autoscaler.name
}