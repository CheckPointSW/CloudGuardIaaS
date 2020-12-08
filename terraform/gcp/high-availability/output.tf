output "cluster_new_created_network" {
  value = module.cluster_network_and_subnet.new_created_network_name
}
output "cluster_new_created_subnet" {
  value = module.cluster_network_and_subnet.new_created_subnet_name
}

output "mgmt_new_created_network" {
  value = module.mgmt_network_and_subnet.new_created_network_name
}
output "mgmt_new_created_subnet" {
  value = module.mgmt_network_and_subnet.new_created_subnet_name
}

output "int_network1_new_created_network" {
  value = module.internal_network1_and_subnet.new_created_network_name
}
output "int_network1_new_created_subnet" {
  value = module.internal_network1_and_subnet.new_created_subnet_name
}

output "int_network2_new_created_network" {
  value = module.internal_network2_and_subnet[*].new_created_network_name
}
output "int_network2_new_created_subnet" {
  value = module.internal_network2_and_subnet[*].new_created_subnet_name
}

output "int_network3_new_created_network" {
  value = module.internal_network3_and_subnet[*].new_created_network_name
}
output "int_network3_new_created_subnet" {
  value = module.internal_network3_and_subnet[*].new_created_subnet_name
}

output "int_network4_new_created_network" {
  value = module.internal_network4_and_subnet[*].new_created_network_name
}
output "int_network4_new_created_subnet" {
  value = module.internal_network4_and_subnet[*].new_created_subnet_name
}

output "int_network5_new_created_network" {
  value = module.internal_network5_and_subnet[*].new_created_network_name
}
output "int_network5_new_created_subnet" {
  value = module.internal_network5_and_subnet[*].new_created_subnet_name
}

output "int_network6_new_created_network" {
  value = module.internal_network6_and_subnet[*].new_created_network_name
}
output "int_network6_new_created_subnet" {
  value = module.internal_network6_and_subnet[*].new_created_subnet_name
}

output "cluster_ICMP_firewall_rule" {
  value = module.cluster_ICMP_firewall_rules[*].firewall_rule_name
}
output "cluster_TCP_firewall_rule" {
  value = module.cluster_TCP_firewall_rules[*].firewall_rule_name
}
output "cluster_UDP_firewall_rule" {
  value = module.cluster_UDP_firewall_rules[*].firewall_rule_name
}
output "cluster_SCTP_firewall_rule" {
  value = module.cluster_SCTP_firewall_rules[*].firewall_rule_name
}
output "cluster_ESP_firewall_rule" {
  value = module.cluster_ESP_firewall_rules[*].firewall_rule_name
}

output "mgmt_ICMP_firewall_rule" {
  value = module.mgmt_ICMP_firewall_rules[*].firewall_rule_name
}
output "mgmt_TCP_firewall_rule" {
  value = module.mgmt_TCP_firewall_rules[*].firewall_rule_name
}
output "mgmt_UDP_firewall_rule" {
  value = module.mgmt_UDP_firewall_rules[*].firewall_rule_name
}
output "mgmt_SCTP_firewall_rule" {
  value = module.mgmt_SCTP_firewall_rules[*].firewall_rule_name
}
output "mgmt_ESP_firewall_rule" {
  value = module.mgmt_ESP_firewall_rules[*].firewall_rule_name
}

output "cluster_ip_external_address" {
  value = google_compute_address.primary_cluster_ip_ext_address.address
}
output "admin_password" {
  value = var.generate_password ? [random_string.generated_password.result] : []
}
output "sic_key" {
  value = var.sic_key
}

output "member_a_name" {
  value = module.members_a_b.member_a_name
}
output "member_a_external_ip" {
  value = module.members_a_b.member_a_external_ip
}
output "member_a_zone" {
  value = var.zoneA
}

output "member_b_name" {
  value = module.members_a_b.member_b_name
}
output "member_b_external_ip" {
  value = module.members_a_b.member_b_external_ip
}
output "member_b_zone" {
  value = var.zoneB
}