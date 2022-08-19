resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

module "cluster_network_and_subnet" {
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "cluster"
  network_cidr = var.cluster_network_cidr
  private_ip_google_access = true
  project = var.project
  region = var.region
  network_name = var.cluster_network_name
}
module "cluster_ICMP_firewall_rules" {
  count = local.cluster_ICMP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "icmp"
  source_ranges = var.cluster_ICMP_traffic
  rule_name = "${var.prefix}-cluster-icmp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  project = var.project
}
module "cluster_TCP_firewall_rules" {
  count = local.cluster_TCP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "tcp"
  source_ranges = var.cluster_TCP_traffic
  rule_name = "${var.prefix}-cluster-tcp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  project = var.project
}
module "cluster_UDP_firewall_rules" {
  count = local.cluster_UDP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "udp"
  source_ranges = var.cluster_UDP_traffic
  rule_name = "${var.prefix}-cluster-udp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  project = var.project
}
module "cluster_SCTP_firewall_rules" {
  count = local.cluster_SCTP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "sctp"
  source_ranges = var.cluster_SCTP_traffic
  rule_name = "${var.prefix}-cluster-sctp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  project = var.project
}
module "cluster_ESP_firewall_rules" {
  count = local.cluster_ESP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "esp"
  source_ranges = var.cluster_ESP_traffic
  rule_name = "${var.prefix}-cluster-esp-${random_string.random_string.result}"
  network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  project = var.project
}

module "mgmt_network_and_subnet" {
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "mgmt"
  network_cidr = var.mgmt_network_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.mgmt_network_name
  project = var.project
}
module "mgmt_ICMP_firewall_rules" {
  count = local.mgmt_ICMP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "icmp"
  source_ranges = var.mgmt_ICMP_traffic
  rule_name = "${var.prefix}-mgmt-icmp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  project = var.project
}
module "mgmt_TCP_firewall_rules" {
  count = local.mgmt_TCP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "tcp"
  source_ranges = var.mgmt_TCP_traffic
  rule_name = "${var.prefix}-mgmt-tcp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  project = var.project
}
module "mgmt_UDP_firewall_rules" {
  count = local.mgmt_UDP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "udp"
  source_ranges = var.mgmt_UDP_traffic
  rule_name = "${var.prefix}-mgmt-udp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  project = var.project
}
module "mgmt_SCTP_firewall_rules" {
  count = local.mgmt_SCTP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "sctp"
  source_ranges = var.mgmt_SCTP_traffic
  rule_name = "${var.prefix}-mgmt-sctp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  project = var.project
}
module "mgmt_ESP_firewall_rules" {
  count = local.mgmt_ESP_traffic_condition
  source = "../common/firewall-rule"

  protocol = "esp"
  source_ranges = var.mgmt_ESP_traffic
  rule_name = "${var.prefix}-mgmt-esp-${random_string.random_string.result}"
  network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  project = var.project
}

module "internal_network1_and_subnet" {
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network1"
  network_cidr = var.internal_network1_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network1_name
}

module "internal_network2_and_subnet" {
  count = var.num_internal_networks < 2 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network2"
  network_cidr = var.internal_network2_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network2_name
}

module "internal_network3_and_subnet" {
  count = var.num_internal_networks < 3 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network3"
  network_cidr = var.internal_network3_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network3_name
}

module "internal_network4_and_subnet" {
  count = var.num_internal_networks < 4 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network4"
  network_cidr = var.internal_network4_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network4_name
}

module "internal_network5_and_subnet" {
  count = var.num_internal_networks < 5 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network5"
  network_cidr = var.internal_network5_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network5_name
}

module "internal_network6_and_subnet" {
  count = var.num_internal_networks < 6 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network6"
  network_cidr = var.internal_network6_cidr
  private_ip_google_access = false
  project = var.project
  region = var.region
  network_name = var.internal_network6_name
}
resource "google_compute_address" "primary_cluster_ip_ext_address" {
  name = "${var.prefix}-primary-cluster-address-${random_string.random_string.result}"
  project = var.project
  region = var.region
}
resource "google_compute_address" "secondary_cluster_ip_ext_address" {
  name = "${var.prefix}-secondary-cluster-address-${random_string.random_string.result}"
  project = var.project
  region = var.region
}
resource "random_string" "generated_password" {
  length = 12
  special = false
}

module "members_a_b" {
  source = "../common/members-a-b"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  region = var.region
  zoneA = var.zoneA
  zoneB = var.zoneB
  machine_type = var.machine_type
  disk_size = var.disk_size
  disk_type = var.disk_type
  image_name = "checkpoint-public/${var.image_name}"
  cluster_network = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_network_link : module.cluster_network_and_subnet.existing_network_link
  cluster_network_subnetwork = local.create_cluster_network_condition ? module.cluster_network_and_subnet.new_created_subnet_link : [var.cluster_network_subnetwork_name]
  mgmt_network = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_network_link : module.mgmt_network_and_subnet.existing_network_link
  mgmt_network_subnetwork = local.create_mgmt_network_condition ? module.mgmt_network_and_subnet.new_created_subnet_link : [var.mgmt_network_subnetwork_name]
  num_internal_networks = var.num_internal_networks
  internal_network1_network = local.create_internal_network1_condition ? module.internal_network1_and_subnet.new_created_network_link : [var.internal_network1_name]
  internal_network1_subnetwork = local.create_internal_network1_condition ? module.internal_network1_and_subnet.new_created_subnet_link : [var.internal_network1_subnetwork_name]
  internal_network2_network = var.num_internal_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_network_link : [var.internal_network2_name]
  internal_network2_subnetwork = var.num_internal_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_subnet_link : [var.internal_network2_subnetwork_name]
  internal_network3_network = var.num_internal_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_network_link : [var.internal_network3_name]
  internal_network3_subnetwork = var.num_internal_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_subnet_link : [var.internal_network3_subnetwork_name]
  internal_network4_network = var.num_internal_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_network_link : [var.internal_network4_name]
  internal_network4_subnetwork = var.num_internal_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_subnet_link : [var.internal_network4_subnetwork_name]
  internal_network5_network = var.num_internal_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_network_link : [var.internal_network5_name]
  internal_network5_subnetwork = var.num_internal_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_subnet_link : [var.internal_network5_subnetwork_name]
  internal_network6_network = var.num_internal_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_network_link : [var.internal_network6_name]
  internal_network6_subnetwork = var.num_internal_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_subnet_link : [var.internal_network6_subnetwork_name]
  admin_SSH_key = var.admin_SSH_key
  generated_admin_password = var.generate_password ? random_string.generated_password.result : ""
  project = var.project
  generate_password = var.generate_password
  sic_key = var.sic_key
  allow_upload_download = var.allow_upload_download
  enable_monitoring = var.enable_monitoring
  admin_shell = var.admin_shell
  management_network = var.management_network
  primary_cluster_address_name = google_compute_address.primary_cluster_ip_ext_address.name
  secondary_cluster_address_name = google_compute_address.secondary_cluster_ip_ext_address.name
}
