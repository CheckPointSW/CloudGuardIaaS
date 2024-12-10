provider "google" {
  credentials = file(var.service_account_path)
  project = var.project
  region = var.region
}
resource "random_string" "mig_random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}
resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}
module "common" {
  source = "../common/common"
  installation_type = "AutoScale"
  os_version = var.os_version
  image_name = var.image_name
  admin_shell = var.admin_shell
  license = var.license
  admin_SSH_key = var.admin_SSH_key
}

module "external_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-ext-network-${random_string.mig_random_string.result}"
    type = "autoscale"
    network_cidr = var.external_network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.external_network_name

}
module "internal_network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-int-network-${random_string.mig_random_string.result}"
    type = "autoscale"
    network_cidr = var.internal_network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.internal_network_name

}

module "network_ICMP_firewall_rules" {
  count = local.ICMP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = var.ICMP_traffic
  rule_name = "${var.prefix}-icmp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
}
module "network_TCP_firewall_rules" {
  count = local.TCP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = var.TCP_traffic
  rule_name = "${var.prefix}-tcp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
}
module "network_UDP_firewall_rules" {
  count = local.UDP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = var.UDP_traffic
  rule_name = "${var.prefix}-udp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
}
module "network_SCTP_firewall_rules" {
  count = local.SCTP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = var.UDP_traffic
  rule_name = "${var.prefix}-sctp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
}
module "network_ESP_firewall_rules" {
  count = local.ESP_traffic_condition == true ? 1 :0
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = var.ESP_traffic
  rule_name = "${var.prefix}-esp-${random_string.random_string.result}"
  network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
}

module "autoscale" {
  source = "../common/autoscale-common"

  service_account_path = var.service_account_path
  project = var.project

  # --- Check Point---
  prefix = var.prefix
  image_name = var.image_name
  os_version = var.os_version
  management_nic = var.management_nic
  management_name = var.management_name
  configuration_template_name = var.configuration_template_name
  generate_password  = var.generate_password
  admin_SSH_key = var.admin_SSH_key
  maintenance_mode_password_hash = var.maintenance_mode_password_hash
  network_defined_by_routes = var.network_defined_by_routes
  admin_shell = var.admin_shell
  allow_upload_download = var.allow_upload_download

  # --- Networking ---
  region = var.region
  external_network = local.create_external_network_condition ? module.external_network_and_subnet.new_created_network_link : module.external_network_and_subnet.existing_network_link
  external_subnetwork  = local.create_external_network_condition ? module.external_network_and_subnet.new_created_subnet_link : [var.external_subnetwork_name]
  internal_network = local.create_internal_network_condition ? module.internal_network_and_subnet.new_created_network_link : module.internal_network_and_subnet.existing_network_link
  internal_subnetwork = local.create_internal_network_condition ? module.internal_network_and_subnet.new_created_subnet_link : [var.internal_subnetwork_name]
  ICMP_traffic = var.ICMP_traffic
  TCP_traffic = var.TCP_traffic
  UDP_traffic = var.UDP_traffic
  SCTP_traffic = var.SCTP_traffic
  ESP_traffic = var.ESP_traffic

  # --- Instance Configuration ---
  machine_type = var.machine_type
  cpu_usage = var.cpu_usage
  instances_min_group_size = var.instances_min_group_size
  instances_max_group_size = var.instances_max_group_size
  disk_type = var.disk_type
  disk_size = var.disk_size
  enable_monitoring = var.enable_monitoring
}