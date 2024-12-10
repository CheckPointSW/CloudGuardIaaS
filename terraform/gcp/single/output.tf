output "network" {
  value =  module.network_and_subnet.new_created_network_name 
}

output "subnetwork" {
  value = module.network_and_subnet.new_created_subnet_name 
}

output "network_ICMP_firewall_rule" {
  value = module.network_ICMP_firewall_rules[*].firewall_rule_name
}
output "network_TCP_firewall_rule" {
  value = module.network_TCP_firewall_rules[*].firewall_rule_name
}
output "network_UDP_firewall_rule" {
  value = module.network_UDP_firewall_rules[*].firewall_rule_name
}
output "network_SCTP_firewall_rule" {
  value = module.network_SCTP_firewall_rules[*].firewall_rule_name
}
output "network_ESP_firewall_rule" {
  value = module.network_ESP_firewall_rules[*].firewall_rule_name
}
output "external_ip" {
  value = module.single.external_nat_ip
}
output "int_network1_new_created_network" {
  value = module.internal_network1_and_subnet[*].new_created_network_name
}
output "int_network1_new_created_subnet" {
  value = module.internal_network1_and_subnet[*].new_created_subnet_name
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
output "int_network7_new_created_network" {
  value = module.internal_network7_and_subnet[*].new_created_network_name
}
output "int_network7_new_created_subnet" {
  value = module.internal_network7_and_subnet[*].new_created_subnet_name
}
output "int_network8_new_created_network" {
  value = module.internal_network8_and_subnet[*].new_created_network_name
}
output "int_network8_new_created_subnet" {
  value = module.internal_network8_and_subnet[*].new_created_subnet_name
}