output "external_network_name" {
  value = google_compute_network.external_network.name
}
output "external_subnetwork_name" {
  value = google_compute_subnetwork.external_subnetwork.name
}
output "internal_network_name" {
  value = google_compute_network.internal_network.name
}
output "internal_subnetwork_name" {
  value = google_compute_subnetwork.internal_subnetwork.name
}

output "SIC_key" {
  value = module.autoscale-into-existing-vpc.SIC_key
}
output "management_name" {
  value = var.management_name
}
output "configuration_template_name" {
  value = var.configuration_template_name
}
output "instance_template_name" {
  value = module.autoscale-into-existing-vpc.instance_template_name
}
output "instance_group_manager_name" {
  value = module.autoscale-into-existing-vpc.instance_group_manager_name
}
output "autoscaler_name" {
  value = module.autoscale-into-existing-vpc.autoscaler_name
}
output "ICMP_firewall_rules_name" {
  value = module.autoscale-into-existing-vpc.ICMP_firewall_rules_name
}
output "TCP_firewall_rules_name" {
  value = module.autoscale-into-existing-vpc.TCP_firewall_rules_name
}
output "UDP_firewall_rules_name" {
  value = module.autoscale-into-existing-vpc.UDP_firewall_rules_name
}
output "SCTP_firewall_rules_name" {
  value = module.autoscale-into-existing-vpc.SCTP_firewall_rules_name
}
output "ESP_firewall_rules_name" {
  value = module.autoscale-into-existing-vpc.ESP_firewall_rules_name
}
