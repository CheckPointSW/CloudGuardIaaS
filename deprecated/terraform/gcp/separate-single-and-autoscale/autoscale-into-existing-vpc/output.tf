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
output "ICMP_firewall_rules_name" {
  value = google_compute_firewall.ICMP_firewall_rules[*].name
}
output "TCP_firewall_rules_name" {
  value = google_compute_firewall.TCP_firewall_rules[*].name
}
output "UDP_firewall_rules_name" {
  value = google_compute_firewall.UDP_firewall_rules[*].name
}
output "SCTP_firewall_rules_name" {
  value = google_compute_firewall.SCTP_firewall_rules[*].name
}
output "ESP_firewall_rules_name" {
  value = google_compute_firewall.ESP_firewall_rules[*].name
}