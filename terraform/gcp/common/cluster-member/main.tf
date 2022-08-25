locals {
  disk_type_condition = var.disk_type == "SSD Persistent Disk" ? "pd-ssd" : var.disk_type == "Standard Persistent Disk" ? "pd-standard" : ""
  admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
}

resource "google_compute_address" "member_ip_address" {
  name = "${var.member_name}-address"
  project = var.project
  region = var.region
}

resource "google_compute_instance" "cluster_member" {
  name = var.member_name
  description = "CloudGuard Highly Available Security Cluster"
  project = var.project
  zone = var.zone
  tags = [
    "checkpoint-gateway"]
  machine_type = var.machine_type
  can_ip_forward = true

  boot_disk {
    auto_delete = true
    device_name = "${var.prefix}-boot"

    initialize_params {
      size = var.disk_size
      type = local.disk_type_condition
      image = var.image_name
    }
  }

  lifecycle {
    ignore_changes = "network_interface.0.access_config"
  }

  network_interface {
    network = var.cluster_network[0]
    subnetwork = var.cluster_network_subnetwork[0]
    subnetwork_project = var.project
  }
  network_interface {
    network = var.mgmt_network[0]
    subnetwork = var.mgmt_network_subnetwork[0]
    access_config {
      nat_ip = google_compute_address.member_ip_address.address
    }
    subnetwork_project = var.project
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks >= 1 ? [
      1] : []
    content {
      network = var.internal_network1_network[0]
      subnetwork = var.internal_network1_subnetwork[0]
      subnetwork_project = var.project
    }
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks >= 2 ? [
      1] : []
    content {
      network = var.internal_network2_network[0]
      subnetwork = var.internal_network2_subnetwork[0]
      subnetwork_project = var.project
    }
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks >= 3 ? [
      1] : []
    content {
      network = var.internal_network3_network[0]
      subnetwork = var.internal_network3_subnetwork[0]
      subnetwork_project = var.project
    }
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks >= 4 ? [
      1] : []
    content {
      network = var.internal_network4_network[0]
      subnetwork = var.internal_network4_subnetwork[0]
      subnetwork_project = var.project
    }
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks >= 5 ? [
      1] : []
    content {
      network = var.internal_network5_network[0]
      subnetwork = var.internal_network5_subnetwork[0]
      subnetwork_project = var.project
    }
  }
  dynamic "network_interface" {
    for_each = var.num_internal_networks == 6 ? [
      1] : []
    content {
      network = var.internal_network6_network[0]
      subnetwork = var.internal_network6_subnetwork[0]
      subnetwork_project = var.project
    }
  }

  service_account {

    scopes = [
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloudruntimeconfig"]
  }

  metadata = local.admin_SSH_key_condition ? {
    instanceSSHKey = var.admin_SSH_key
    adminPasswordSourceMetadata = var.generate_password ? var.generated_admin_password : ""
  } : { adminPasswordSourceMetadata = var.generate_password ? var.generated_admin_password : "" }

  metadata_startup_script = templatefile("${path.module}/../startup-script.sh", {
    // script's arguments
    generatePassword = var.generate_password
    config_url = "https://runtimeconfig.googleapis.com/v1beta1/projects/${var.project}/configs/${var.prefix}-config"
    config_path = "projects/${var.project}/configs/${var.prefix}-config"
    sicKey = var.sic_key
    allowUploadDownload = var.allow_upload_download
    templateName = "cluster_tf"
    templateVersion = "20201206"
    templateType = "terraform"
    mgmtNIC = ""
    hasInternet = "true"
    enableMonitoring = var.enable_monitoring
    shell = var.admin_shell
    installationType = "Cluster"
    computed_sic_key = ""
    managementGUIClientNetwork = ""
    primary_cluster_address_name = var.primary_cluster_address_name
    secondary_cluster_address_name = var.secondary_cluster_address_name
    managementNetwork = var.management_network
  })
}
