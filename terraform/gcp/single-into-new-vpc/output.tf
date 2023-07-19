output "network" {
  value = google_compute_network.network.name
}
output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.name
}
output "internal_network" {
  value = google_compute_network.internal_network.name
}
output "internal_subnetwork" {
  value = google_compute_subnetwork.internal_subnetwork.name
}
output "SIC_key" {
  value = module.single-into-existing-vpc.SIC_key
}
output "ICMP_firewall_rules_name" {
  value = module.single-into-existing-vpc.ICMP_firewall_rules_name
}
output "TCP_firewall_rules_name" {
  value = module.single-into-existing-vpc.TCP_firewall_rules_name
}
output "UDP_firewall_rules_name" {
  value = module.single-into-existing-vpc.UDP_firewall_rules_name
}
output "SCTP_firewall_rules_name" {
  value = module.single-into-existing-vpc.SCTP_firewall_rules_name
}
output "ESP_firewall_rules_name" {
  value = module.single-into-existing-vpc.ESP_firewall_rules_name
}
