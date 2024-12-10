locals {
  create_network_condition = var.network_cidr == "" ? false : true

  create_internal_network1_condition = var.internal_network1_cidr != "" && var.num_additional_networks >= 1 ? true : false
  create_internal_network2_condition = var.internal_network2_cidr != "" && var.num_additional_networks >= 2 ? true : false
  create_internal_network3_condition = var.internal_network3_cidr != "" && var.num_additional_networks >= 3 ? true : false
  create_internal_network4_condition = var.internal_network4_cidr != "" && var.num_additional_networks >= 4 ? true : false
  create_internal_network5_condition = var.internal_network5_cidr != "" && var.num_additional_networks >= 5 ? true : false
  create_internal_network6_condition = var.internal_network6_cidr != "" && var.num_additional_networks >= 6 ? true : false
  create_internal_network7_condition = var.internal_network5_cidr != "" && var.num_additional_networks >= 7 ? true : false
  create_internal_network8_condition = var.internal_network6_cidr != "" && var.num_additional_networks >= 8 ? true : false

  TCP_traffic_condition = length(var.TCP_traffic) == 0 ? 0 : 1
  ICMP_traffic_condition = length(var.ICMP_traffic) == 0 ? 0 : 1
  UDP_traffic_condition = length(var.UDP_traffic) == 0 ? 0 : 1
  SCTP_traffic_condition = length(var.SCTP_traffic) == 0 ? 0 : 1
  ESP_traffic_condition = length(var.ESP_traffic) == 0 ? 0 : 1

  validate_management_without_public_ip = var.installation_type == "Management only" && var.external_ip == "none" ? index("error:" , "using management externalIP cannot be none") : 0
  validate_management_additional_networks = var.installation_type == "Management only" && var.num_additional_networks > 0  ? index("error:" , "If you create a management only installation, you cant have additional network") : 0

  validate_gateway_additional_networks = var.installation_type == "Gateway only" && var.num_additional_networks <= 0  ?  index("error:" , "If you create a gateway only installation, you need to have additional networks 1-8") : 0
}