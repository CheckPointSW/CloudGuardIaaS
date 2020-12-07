locals {
  create_network_condition = var.network_cidr == "" ? false : true
}

resource "google_compute_network" "network" {
  count = local.create_network_condition ? 1 : 0
  name = substr(format("${var.prefix}-${var.type}-%s", replace(uuid(), "-", "")), 0, length("${var.prefix}-${var.type}-")+5)
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnetwork" {
  count = local.create_network_condition ? 1 : 0
  name = substr(format("${var.prefix}-${var.type}-subnet-%s", replace(uuid(), "-", "")), 0, length("${var.prefix}-${var.type}-subnet-")+5)
  ip_cidr_range = var.network_cidr
  private_ip_google_access = true
  region = var.region
  network = google_compute_network.network[count.index].id
}
data "google_compute_network" "network_name" {
  count = local.create_network_condition ? 0 : 1
  name = var.network_name
}