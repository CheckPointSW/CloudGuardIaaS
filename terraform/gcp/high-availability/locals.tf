locals {

  split_zoneA = split("-", var.zone_a)
  split_zoneB = split("-", var.zone_b)
  // will fail if the var.zoneA and var.zoneB are not at the same region:
  validate_zones = index(local.split_zoneA, local.split_zoneB[0]) == local.split_zoneA[0] && index(local.split_zoneA, local.split_zoneB[1]) == local.split_zoneA[0] ? 0 : "var.zoneA and var.zoneB are not at the same region"

 regex_valid_management_network = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))|(S1C)$"
  // Will fail if var.management_network is invalid
  regex_management_network = regex(local.regex_valid_management_network, var.management_network) == var.management_network ? 0 : "Variable [management_network] must be a valid address in CIDR notation or S1C."

  regex_valid_network_cidr = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))|$"

  // Will fail if var.cluster_network_cidr is invalid
  regex_cluster_network_cidr = regex(local.regex_valid_network_cidr, var.cluster_network_cidr) == var.cluster_network_cidr ? 0 : "Variable [cluster_network_cidr] must be a valid address in CIDR notation."
  // Will fail if var.mgmt_network_cidr is invalid
  regex_mgmt_network_cidr = regex(local.regex_valid_network_cidr, var.mgmt_network_cidr) == var.mgmt_network_cidr ? 0 : "Variable [mgmt_network_cidr] must be a valid address in CIDR notation."
  // Will fail if var.internal_network1_cidr is invalid
  regex_internal_network1_cidr = regex(local.regex_valid_network_cidr, var.internal_network1_cidr) == var.internal_network1_cidr ? 0 : "Variable [internal_network1_cidr] must be a valid address in CIDR notation."

  disk_type_allowed_values = [
    "SSD Persistent Disk",
    "Standard Persistent Disk"]
  // Will fail if var.disk_type is invalid
  validate_disk_type = index(local.disk_type_allowed_values, var.disk_type)


  // Will fail if var.cluster_network_name or var.cluster_network_subnetwork_name are empty double quotes in case of use existing network.
  validate_cluster_network = var.cluster_network_cidr == "" && var.cluster_network_name == "" ? index("error:", "using existing cluster network - cluster network name is missing") : 0
  validate_cluster_subnet = var.cluster_network_cidr == "" && var.cluster_network_subnetwork_name == "" ? index("error:", "using existing cluster network - cluster subnetwork name is missing") : 0

  // Will fail if var.mgmt_network_name or var.mgmt_network_subnetwork_name are empty double quotes in case of use existing network.
  validate_mgmt_network = var.mgmt_network_cidr == "" && var.mgmt_network_name == "" ? index("error:", "using existing mgmt network - mgmt network name is missing") : 0
  validate_mgmt_subnet = var.mgmt_network_cidr == "" && var.mgmt_network_subnetwork_name == "" ? index("error:", "using existing mgmt network - mgmt subnetwork name is missing") : 0

  // Will fail if var.internal_network1_name or var.internal_network1_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network1 = var.internal_network1_cidr == "" && var.internal_network1_name == "" ? index("error:", "using existing network1 - internal network1 name is missing") : 0
  validate_internal_network1_subnet = var.internal_network1_cidr == "" && var.internal_network1_subnetwork_name == "" ? ("using existing network1 - internal network1 subnet name is missing") : 0

  // Will fail if var.internal_network2_name or var.internal_network2_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network2 = var.num_internal_networks >= 2 && var.internal_network2_cidr == "" && var.internal_network2_name == "" ? index("error:", "using existing network2 - internal network2 name is missing") : 0
  validate_internal_network2_subnet = var.num_internal_networks >= 2 && var.internal_network2_cidr == "" && var.internal_network2_subnetwork_name == "" ? index("error:", "using existing network2 - internal network2 subnet name is missing") : 0

  // Will fail if var.internal_network3_name or var.internal_network3_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network3 = var.num_internal_networks >= 3 && var.internal_network3_cidr == "" && var.internal_network3_name == "" ? index("error:", "using existing network3 - internal network3 name is missing") : 0
  validate_internal_network3_subnet = var.num_internal_networks >= 3 && var.internal_network3_cidr == "" && var.internal_network3_subnetwork_name == "" ? index("error:", "using existing network3 - internal network3 subnet name is missing") : 0

  // Will fail if var.internal_network4_name or var.internal_network4_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network4 = var.num_internal_networks >= 4 && var.internal_network4_cidr == "" && var.internal_network4_name == "" ? index("error:", "using existing network4 - internal network4 name is missing") : 0
  validate_internal_network4_subnet = var.num_internal_networks >= 4 && var.internal_network4_cidr == "" && var.internal_network4_subnetwork_name == "" ? index("error:", "using existing network4 - internal network4 subnet name is missing") : 0

  // Will fail if var.internal_network5_name or var.internal_network5_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network5 = var.num_internal_networks >= 5 && var.internal_network5_cidr == "" && var.internal_network5_name == "" ? index("error:", "using existing network5 - internal network5 name is missing") : 0
  validate_internal_network5_subnet = var.num_internal_networks >= 5 && var.internal_network5_cidr == "" && var.internal_network5_subnetwork_name == "" ? index("error:", "using existing network5 - internal network5 subnet name is missing") : 0

  // Will fail if var.internal_network6_name or var.internal_network6_subnetwork_name are empty double quotes in case of use existing network.
  validate_internal_network6 = var.num_internal_networks >= 6 && var.internal_network6_cidr == "" && var.internal_network6_name == "" ? index("error:", "using existing network6 - internal network6 name is missing") : 0
  validate_internal_network6_subnet = var.num_internal_networks >= 6 && var.internal_network6_cidr == "" && var.internal_network6_subnetwork_name == "" ? index("error:", "using existing network6 - internal network6 subnet name is missing") : 0


  regex_valid_sic_key = "^([a-z0-9A-Z]{8,30})$"
  // Will fail if var.sic_key is invalid
  regex_sic_key = length(regexall(local.regex_valid_sic_key, var.sic_key) )> 0  ? 0 : "Variable [sicKey] must be at least 8 alphanumeric characters."
  index_sic_key  = index(["0"], local.regex_sic_key)


  create_cluster_network_condition = var.cluster_network_cidr == "" ? false : true
  create_mgmt_network_condition = var.mgmt_network_cidr == "" ? false : true
  create_internal_network1_condition = var.internal_network1_cidr == "" ? false : true
  create_internal_network2_condition = var.internal_network2_cidr == "" && var.num_internal_networks >= 2 ? false : true
  create_internal_network3_condition = var.internal_network3_cidr == "" && var.num_internal_networks >= 3 ? false : true
  create_internal_network4_condition = var.internal_network4_cidr == "" && var.num_internal_networks >= 4 ? false : true
  create_internal_network5_condition = var.internal_network5_cidr == "" && var.num_internal_networks >= 5 ? false : true
  create_internal_network6_condition = var.internal_network6_cidr == "" && var.num_internal_networks == 6 ? false : true
  cluster_ICMP_traffic_condition = length(var.cluster_ICMP_traffic) == 0 ? 0 : 1
  cluster_TCP_traffic_condition = length(var.cluster_TCP_traffic) == 0 ? 0 : 1
  cluster_UDP_traffic_condition = length(var.cluster_UDP_traffic) == 0 ? 0 : 1
  cluster_SCTP_traffic_condition = length(var.cluster_SCTP_traffic) == 0 ? 0 : 1
  cluster_ESP_traffic_condition = length(var.cluster_ESP_traffic) == 0 ? 0 : 1
  mgmt_ICMP_traffic_condition = length(var.mgmt_ICMP_traffic) == 0 ? 0 : 1
  mgmt_TCP_traffic_condition = length(var.mgmt_TCP_traffic) == 0 ? 0 : 1
  mgmt_UDP_traffic_condition = length(var.mgmt_UDP_traffic) == 0 ? 0 : 1
  mgmt_SCTP_traffic_condition = length(var.mgmt_SCTP_traffic) == 0 ? 0 : 1
  mgmt_ESP_traffic_condition = length(var.mgmt_ESP_traffic) == 0 ? 0 : 1
}