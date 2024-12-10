output "SIC_key" {
  value = random_string.random_sic_key.result
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