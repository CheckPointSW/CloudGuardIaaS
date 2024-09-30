provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
  region      = var.region
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

resource "google_compute_network" "network" {
  name = "${var.prefix}-network-${random_string.random_string.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name = "${var.prefix}-subnetwork-${random_string.random_string.result}"
  ip_cidr_range = var.subnetwork_cidr
  private_ip_google_access = true
  region = var.region
  network = google_compute_network.network.id
}

resource "google_compute_network" "internal_network" {
  name = "${var.prefix}-internal-network-${random_string.random_string.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "internal_subnetwork" {
  name = "${var.prefix}-internal-subnetwork-${random_string.random_string.result}"
  ip_cidr_range = var.internal_subnetwork_cidr
  private_ip_google_access = true
  region = var.region
  network = google_compute_network.internal_network.id
}


module "single-into-existing-vpc" {
  source = "../single-into-existing-vpc"

  service_account_path = var.service_account_path
  project = var.project


  # --- Check Point Deployment---
  image_name = var.image_name
  os_version = var.os_version
  installationType = var.installationType
  license = var.license
  prefix = var.prefix
  management_nic = var.management_nic
  admin_shell = var.admin_shell
  admin_SSH_key = var.admin_SSH_key
  maintenance_mode_password_hash = var.maintenance_mode_password_hash
  generatePassword = var.generatePassword
  allowUploadDownload = var.allowUploadDownload
  sicKey = var.sicKey
  managementGUIClientNetwork = var.managementGUIClientNetwork

  # --- Quick connect to Smart-1 Cloud ---
  smart_1_cloud_token = var.smart_1_cloud_token

  # --- Networking ---
  zone = var.zone
  network = [google_compute_network.network.name]
  subnetwork = [google_compute_subnetwork.subnetwork.name]
  network_enableTcp = var.network_enableTcp
  network_tcpSourceRanges = var.network_tcpSourceRanges
  network_enableGwNetwork = var.network_enableGwNetwork
  network_gwNetworkSourceRanges = var.network_gwNetworkSourceRanges
  network_enableIcmp = var.network_enableIcmp
  network_icmpSourceRanges = var.network_icmpSourceRanges
  network_enableUdp = var.network_enableUdp
  network_udpSourceRanges = var.network_udpSourceRanges
  network_enableSctp = var.network_enableSctp
  network_sctpSourceRanges = var.network_sctpSourceRanges
  network_enableEsp = var.network_enableEsp
  network_espSourceRanges = var.network_espSourceRanges
  numAdditionalNICs = var.numAdditionalNICs
  externalIP = var.externalIP
  internal_network1_network = [google_compute_network.internal_network.name]
  internal_network1_subnetwork = [google_compute_subnetwork.internal_subnetwork.name]

  # --- Instances configuration---
  machine_type = var.machine_type
  diskType = var.diskType
  bootDiskSizeGb = var.bootDiskSizeGb
  enableMonitoring = var.enableMonitoring
}