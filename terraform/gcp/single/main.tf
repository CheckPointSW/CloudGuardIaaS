provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
  region      = var.region
}
resource "random_string" "random_string" {
  length  = 5
  special = false
  upper   = false
  keepers = {}
}
module "common" {
  source = "../common/common"
  installation_type = var.installation_type
  os_version = var.os_version
  image_name = var.image_name
  admin_shell = var.admin_shell
  license = var.license
  admin_SSH_key = var.admin_SSH_key
}

module "network_and_subnet" {
    source = "../common/network-and-subnet"
    prefix = "${var.prefix}-${random_string.random_string.result}"
    type = replace(lower(var.installation_type), " ", "-")
    network_cidr = var.network_cidr
    private_ip_google_access = true
    region = var.region
    network_name = var.network_name

}
module "network_ICMP_firewall_rules" {
  count = local.ICMP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "icmp"
  source_ranges = var.ICMP_traffic
  rule_name = "${var.prefix}-${replace(replace(replace(lower(var.installation_type), "(", ""), ")", ""), " ", "-")}-icmp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
}
module "network_TCP_firewall_rules" {
  count = local.TCP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "tcp"
  source_ranges = var.TCP_traffic
  rule_name = "${var.prefix}-${replace(replace(replace(lower(var.installation_type), "(", ""), ")", ""), " ", "-")}-tcp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
}
module "network_UDP_firewall_rules" {
  count = local.UDP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "udp"
  source_ranges = var.UDP_traffic
  rule_name = "${var.prefix}-${replace(replace(replace(lower(var.installation_type), "(", ""), ")", ""), " ", "-")}-udp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
}
module "network_SCTP_firewall_rules" {
  count = local.SCTP_traffic_condition
  source = "../common/firewall-rule"
  protocol = "sctp"
  source_ranges = var.SCTP_traffic
  rule_name = "${var.prefix}-${replace(replace(replace(lower(var.installation_type), "(", ""), ")", ""), " ", "-")}-sctp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
}
module "network_ESP_firewall_rules" {
  count = local.ESP_traffic_condition 
  source = "../common/firewall-rule"
  protocol = "esp"
  source_ranges = var.ESP_traffic
  rule_name = "${var.prefix}-${replace(replace(replace(lower(var.installation_type), "(", ""), ")", ""), " ", "-")}-esp-${random_string.random_string.result}"
  network = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
}

module "internal_network1_and_subnet" {
  count = local.create_internal_network1_condition ? 1 : 0
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network1"
  network_cidr = var.internal_network1_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network1_name
}
module "internal_network2_and_subnet" {
  count = local.create_internal_network2_condition ? 1 : 0
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network2"
  network_cidr = var.internal_network2_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network2_name
}
module "internal_network3_and_subnet" {
  count = var.num_additional_networks < 3 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network3"
  network_cidr = var.internal_network3_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network3_name
}
module "internal_network4_and_subnet" {
  count = var.num_additional_networks < 4 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network4"
  network_cidr = var.internal_network4_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network4_name
}
module "internal_network5_and_subnet" {
  count = var.num_additional_networks < 5 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network5"
  network_cidr = var.internal_network5_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network5_name
}
module "internal_network6_and_subnet" {
  count = var.num_additional_networks < 6 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network6"
  network_cidr = var.internal_network6_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network6_name
}
module "internal_network7_and_subnet" {
  count = var.num_additional_networks < 7 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network7"
  network_cidr = var.internal_network7_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network7_name
}
module "internal_network8_and_subnet" {
  count = var.num_additional_networks < 8 ? 0 : 1
  source = "../common/network-and-subnet"

  prefix = "${var.prefix}-${random_string.random_string.result}"
  type = "internal-network8"
  network_cidr = var.internal_network8_cidr
  private_ip_google_access = false
  region = var.region
  network_name = var.internal_network8_name
}
module "single" {
  source = "../common/single-common"
  project              = var.project

  # Check Point Deployment
  image_name                       = var.image_name
  os_version                       = var.os_version
  installation_type                 = var.installation_type
  prefix                           = var.prefix
  management_nic                   = var.management_nic
  admin_shell                      = var.admin_shell
  admin_SSH_key                    = var.admin_SSH_key
  maintenance_mode_password_hash   = var.maintenance_mode_password_hash
  generate_password                 = var.generate_password
  allow_upload_download              = var.allow_upload_download
  sic_key                           = var.sic_key
  management_gui_client_network       = var.management_gui_client_network

  # Smart-1 Cloud
  smart_1_cloud_token = var.smart_1_cloud_token

  # Networking
  zone                  = var.zone
  network               = local.create_network_condition ? module.network_and_subnet.new_created_network_link : module.network_and_subnet.existing_network_link
  subnetwork            = local.create_network_condition ? module.network_and_subnet.new_created_subnet_link : [var.subnetwork_name]
  num_additional_networks = var.num_additional_networks
  external_ip            = var.external_ip

  #Internal networks
  internal_network1_network = var.num_additional_networks < 1 ? [] : local.create_internal_network1_condition ? module.internal_network1_and_subnet[0].new_created_network_link : [var.internal_network1_name]
  internal_network1_subnetwork = var.num_additional_networks < 1 ? [] : local.create_internal_network1_condition ? module.internal_network1_and_subnet[0].new_created_subnet_link : [var.internal_network1_subnetwork_name]
  internal_network2_network = var.num_additional_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_network_link : [var.internal_network2_name]
  internal_network2_subnetwork = var.num_additional_networks < 2 ? [] : local.create_internal_network2_condition ? module.internal_network2_and_subnet[0].new_created_subnet_link : [var.internal_network2_subnetwork_name]
  internal_network3_network = var.num_additional_networks < 3 ? [] : local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_network_link : [var.internal_network3_name]
  internal_network3_subnetwork = var.num_additional_networks < 3 ? [] :local.create_internal_network3_condition ? module.internal_network3_and_subnet[0].new_created_subnet_link : [var.internal_network3_subnetwork_name]
  internal_network4_network = var.num_additional_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_network_link : [var.internal_network4_name]
  internal_network4_subnetwork = var.num_additional_networks < 4 ? [] : local.create_internal_network4_condition ? module.internal_network4_and_subnet[0].new_created_subnet_link : [var.internal_network4_subnetwork_name]
  internal_network5_network = var.num_additional_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_network_link : [var.internal_network5_name]
  internal_network5_subnetwork = var.num_additional_networks < 5 ? [] : local.create_internal_network5_condition ? module.internal_network5_and_subnet[0].new_created_subnet_link : [var.internal_network5_subnetwork_name]
  internal_network6_network = var.num_additional_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_network_link : [var.internal_network6_name]
  internal_network6_subnetwork = var.num_additional_networks < 6 ? [] : local.create_internal_network6_condition ? module.internal_network6_and_subnet[0].new_created_subnet_link : [var.internal_network6_subnetwork_name]
  internal_network7_network = var.num_additional_networks < 7 ? [] : local.create_internal_network7_condition ? module.internal_network7_and_subnet[0].new_created_network_link : [var.internal_network7_name]
  internal_network7_subnetwork = var.num_additional_networks < 7 ? [] : local.create_internal_network7_condition ? module.internal_network7_and_subnet[0].new_created_subnet_link : [var.internal_network7_subnetwork_name]
  internal_network8_network = var.num_additional_networks < 8 ? [] : local.create_internal_network8_condition ? module.internal_network8_and_subnet[0].new_created_network_link : [var.internal_network8_name]
  internal_network8_subnetwork = var.num_additional_networks < 8 ? [] : local.create_internal_network8_condition ? module.internal_network8_and_subnet[0].new_created_subnet_link : [var.internal_network8_subnetwork_name]

  # Instances configuration
  machine_type = var.machine_type
  disk_type     = var.disk_type
  disk_size = var.disk_size
  enable_monitoring = var.enable_monitoring
}