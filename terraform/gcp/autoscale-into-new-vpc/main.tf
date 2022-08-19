resource "random_string" "mig_random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}
resource "google_compute_network" "external_network" {
  name = "${var.prefix}-ext-network-${random_string.mig_random_string.result}"
  project = var.project
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "external_subnetwork" {
  name = "${var.prefix}-ext-subnet-${random_string.mig_random_string.result}"
  ip_cidr_range = var.external_subnetwork_ip_cidr_range
  project = var.project
  region = var.region
  network = google_compute_network.external_network.id
}

resource "google_compute_network" "internal_network" {
  name = "${var.prefix}-int-network-${random_string.mig_random_string.result}"
  project = var.project
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "internal_subnetwork" {
  name = "${var.prefix}-int-subnet-${random_string.mig_random_string.result}"
  ip_cidr_range = var.internal_subnetwork_ip_cidr_range
  project = var.project
  region = var.region
  network = google_compute_network.internal_network.id
}


module "autoscale-into-existing-vpc" {
  source = "../autoscale-into-existing-vpc"

  service_account_path = var.service_account_path
  project = var.project

  # --- Check Point---
  prefix = var.prefix
  image_name = var.image_name
  management_nic = var.management_nic
  management_name = var.management_name
  configuration_template_name = var.configuration_template_name
  admin_SSH_key = var.admin_SSH_key
  network_defined_by_routes = var.network_defined_by_routes
  admin_shell = var.admin_shell
  allow_upload_download = var.allow_upload_download

  # --- Networking ---
  region = var.region
  external_network_name = google_compute_network.external_network.name
  external_subnetwork_name = google_compute_subnetwork.external_subnetwork.name
  internal_network_name = google_compute_network.internal_network.name
  internal_subnetwork_name = google_compute_subnetwork.internal_subnetwork.name
  ICMP_traffic = var.ICMP_traffic
  TCP_traffic = var.TCP_traffic
  UDP_traffic = var.UDP_traffic
  SCTP_traffic = var.SCTP_traffic
  ESP_traffic = var.ESP_traffic

  # --- Instance Configuration ---
  machine_type = var.machine_type
  cpu_usage = var.cpu_usage
  instances_min_grop_size = var.instances_min_grop_size
  instances_max_grop_size = var.instances_max_grop_size
  disk_type = var.disk_type
  disk_size = var.disk_size
  enable_monitoring = var.enable_monitoring
}
