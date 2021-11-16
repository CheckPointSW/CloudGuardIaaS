provider "google" {
  credentials = file(var.service_account_path)
  project = var.project
  region = var.region
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}
data "google_compute_network" "external_network" {
  name = var.external_network_name
}
data "google_compute_network" "internal_network" {
  name = var.internal_network_name
}
resource "random_string" "random_sic_key" {
  length = 12
  special = false
}

resource "google_compute_instance_template" "instance_template" {
  name = "${var.prefix}-tmplt-${random_string.random_string.result}"
  machine_type = var.machine_type
  can_ip_forward = true


  disk {
    source_image = "checkpoint-public/${var.image_name}"
    auto_delete = true
    boot = true
    device_name = "${var.prefix}-boot-${random_string.random_string.result}"
    disk_type = local.disk_type_condition
    disk_size_gb = var.disk_size
    mode = "READ_WRITE"
    type = "PERSISTENT"
  }

  network_interface {
    network = data.google_compute_network.external_network.self_link
    subnetwork = var.external_subnetwork_name
    dynamic "access_config" {
      for_each = local.mgmt_nic_condition ? [
        1] : []
      content {
        network_tier = local.mgmt_nic_condition ? "PREMIUM" : "STANDARD"
      }
    }
  }

  network_interface {
    network = data.google_compute_network.internal_network.self_link
    subnetwork = var.internal_subnetwork_name
  }

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    preemptible = false
  }

  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"]
  }
  tags = [
    format("x-chkp-management--%s", var.management_name),
    format("x-chkp-template--%s", var.configuration_template_name),
    "checkpoint-gateway",
    local.mgmt_nic_ip_address_condition,
    local.mgmt_nic_interface_condition,
    local.network_defined_by_routes_condition,
    local.network_defined_by_routes_settings_condition]

  metadata_startup_script = templatefile("${path.module}/../common/startup-script.sh", {
    // script's arguments
    generatePassword = "false"
    config_url = ""
    config_path = ""
    sicKey = ""
    allowUploadDownload = var.allow_upload_download
    templateName = "autoscale_tf"
    templateVersion = "20201206"
    templateType = "terraform"
    mgmtNIC = var.management_nic
    hasInternet = "false"
    enableMonitoring = var.enable_monitoring
    shell = var.admin_shell
    installationType = "AutoScale"
    computed_sic_key = random_string.random_sic_key.result
    managementGUIClientNetwork = ""
    primary_cluster_address_name = ""
    secondary_cluster_address_name = ""
    managementNetwork = ""
  })

  metadata = local.admin_SSH_key_condition ? {
    serial-port-enable = "true"
    instanceSSHKey = var.admin_SSH_key
  } : {
    serial-port-enable = "true"
  }
}

resource "google_compute_firewall" "ICMP_firewall_rules" {
  count = local.ICMP_traffic_condition
  name = "${var.prefix}-icmp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "icmp"
  }
  source_ranges = var.ICMP_traffic
  target_tags = [
    "checkpoint-gateway"]
}
resource "google_compute_firewall" "TCP_firewall_rules" {
  count = local.TCP_traffic_condition
  name = "${var.prefix}-tcp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "tcp"
  }
  source_ranges = var.TCP_traffic
  target_tags = [
    "checkpoint-gateway"]
}
resource "google_compute_firewall" "UDP_firewall_rules" {
  count = local.UDP_traffic_condition
  name = "${var.prefix}-udp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "udp"
  }
  source_ranges = var.UDP_traffic
  target_tags = [
    "checkpoint-gateway"]
}
resource "google_compute_firewall" "SCTP_firewall_rules" {
  count = local.SCTP_traffic_condition
  name = "${var.prefix}-sctp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "sctp"
  }
  source_ranges = var.SCTP_traffic
  target_tags = [
    "checkpoint-gateway"]
}
resource "google_compute_firewall" "ESP_firewall_rules" {
  count = local.ESP_traffic_condition
  name = "${var.prefix}-esp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "esp"
  }
  source_ranges = var.ESP_traffic
  target_tags = [
    "checkpoint-gateway"]
}
resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  region = var.region
  name = "${var.prefix}-igm-${random_string.random_string.result}"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name = "${var.prefix}-tmplt"
  }
  base_instance_name = "${var.prefix}-${random_string.random_string.result}"
}
resource "google_compute_region_autoscaler" "autoscaler" {
  region = var.region
  name = "${var.prefix}-autoscaler-${random_string.random_string.result}"
  target = google_compute_region_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas = var.instances_max_grop_size
    min_replicas = var.instances_min_grop_size
    cooldown_period = 90

    cpu_utilization {
      target = var.cpu_usage/100
    }
  }
}
