provider "google" {
  credentials = file(var.service_account_path)
  project = var.project
  zone = var.zone
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}
data "google_compute_network" "external_network" {
  name = var.network[0]
}
resource "random_string" "random_sic_key" {
  length = 12
  special = false
}

resource "google_compute_firewall" "ICMP_firewall_rules" {
  count = local.ICMP_traffic_condition
  name = "${var.prefix}-icmp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "icmp"
  }
  source_ranges = var.network_icmpSourceRanges
  target_tags = [
    "checkpoint-${replace(replace(lower(var.installationType)," ","-"),"(standalone)","standalone")}"]
}
resource "google_compute_firewall" "TCP_firewall_rules" {
  count = local.TCP_traffic_condition
  name = "${var.prefix}-tcp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "tcp"
  }
  source_ranges = var.network_tcpSourceRanges
  target_tags = [
    "checkpoint-${replace(replace(lower(var.installationType)," ","-"),"(standalone)","standalone")}"]
}
resource "google_compute_firewall" "UDP_firewall_rules" {
  count = local.UDP_traffic_condition
  name = "${var.prefix}-udp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "udp"
  }
  source_ranges = var.network_udpSourceRanges
  target_tags = [
    "checkpoint-${replace(replace(lower(var.installationType)," ","-"),"(standalone)","standalone")}"]
}
resource "random_string" "generated_password" {
  length = 12
  special = false
}
resource "google_compute_firewall" "SCTP_firewall_rules" {
  count = local.SCTP_traffic_condition
  name = "${var.prefix}-sctp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "sctp"
  }
  source_ranges = var.network_sctpSourceRanges
  target_tags = [
    "checkpoint-${replace(replace(lower(var.installationType)," ","-"),"(standalone)","standalone")}"]
}
resource "google_compute_firewall" "ESP_firewall_rules" {
  count = local.ESP_traffic_condition
  name = "${var.prefix}-esp-${random_string.random_string.result}"
  network = data.google_compute_network.external_network.self_link
  allow {
    protocol = "esp"
  }
  source_ranges = var.network_espSourceRanges
  target_tags = [
    "checkpoint-${replace(replace(lower(var.installationType)," ","-"),"(standalone)","standalone")}"]
}

resource "google_compute_instance" "gateway" {
  name = "${var.prefix}-${random_string.random_string.result}"
  description = "Check Point Security ${replace(var.installationType,"(Standalone)","--")==var.installationType?split(" ",var.installationType)[0]:" Gateway and Management"}"
  zone = var.zone
  labels = {goog-dm = "${var.prefix}-${random_string.random_string.result}"}
  tags =replace(var.installationType,"(Standalone)","--")==var.installationType?[
    "checkpoint-${split(" ",lower(var.installationType))[0]}","${var.prefix}${random_string.random_string.result}"
  ]:["checkpoint-gateway","checkpoint-management","${var.prefix}${random_string.random_string.result}"]
  machine_type = var.machine_type
  can_ip_forward = var.installationType == "Management only"? false:true
  boot_disk {
    auto_delete = true
    device_name = "chkp-single-boot-${random_string.random_string.result}"
    initialize_params {
      size = var.bootDiskSizeGb
      type = local.disk_type_condition
      image = "checkpoint-public/${var.image_name}"
    }
  }
  network_interface {
    network = var.network[0]
    subnetwork = var.subnetwork[0]
    dynamic "access_config" {
      for_each = var.externalIP == "None"? []:[1]
      content {
        nat_ip = var.externalIP=="static" ? google_compute_address.static.address : null
      }
    }

  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 1 ? [
      1] : []
    content {
      network = var.internal_network1_network[0]
      subnetwork = var.internal_network1_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 2 ? [
      1] : []
    content {
      network = var.internal_network2_network[0]
      subnetwork = var.internal_network2_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 3 ? [
      1] : []
    content {
      network = var.internal_network3_network[0]
      subnetwork = var.internal_network3_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 4 ? [
      1] : []
    content {
      network = var.internal_network4_network[0]
      subnetwork = var.internal_network4_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs >= 5 ? [
      1] : []
    content {
      network = var.internal_network5_network[0]
      subnetwork = var.internal_network5_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 6 ? [
      1] : []
    content {
      network = var.internal_network6_network[0]
      subnetwork = var.internal_network6_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 7 ? [
      1] : []
    content {
      network = var.internal_network7_network[0]
      subnetwork = var.internal_network7_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.numAdditionalNICs == 8 ? [
      1] : []
    content {
      network = var.internal_network8_network[0]
      subnetwork = var.internal_network8_subnetwork[0]
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloudruntimeconfig",
      "https://www.googleapis.com/auth/monitoring.write"]
  }

  metadata = local.admin_SSH_key_condition ? {
    instanceSSHKey = var.admin_SSH_key
    adminPasswordSourceMetadata = var.generatePassword ?random_string.generated_password.result : ""
  } : {adminPasswordSourceMetadata = var.generatePassword?random_string.generated_password.result : ""}

  metadata_startup_script = templatefile("${path.module}/../common/startup-script.sh", {
    // script's arguments
    generatePassword = var.generatePassword
    config_url = "https://runtimeconfig.googleapis.com/v1beta1/projects/${var.project}/configs/-config"
    config_path = "projects/${var.project}/configs/-config"
    sicKey = ""
    allowUploadDownload = var.allowUploadDownload
    templateName = "single_tf"
    templateVersion = "20230109"
    templateType = "terraform"
    hasInternet = "true"
    enableMonitoring = var.enableMonitoring
    shell = var.admin_shell
    installationType = var.installationType
    computed_sic_key = var.sicKey
    managementGUIClientNetwork = var.managementGUIClientNetwork
    installSecurityManagement = true
    primary_cluster_address_name = ""
    secondary_cluster_address_name = ""
    subnet_router_meta_path = ""
    mgmtNIC = var.management_nic
    managementNetwork = ""
    numAdditionalNICs = ""
    smart_1_cloud_token = var.smart_1_cloud_token
    name = ""
    zoneConfig = ""
    region = ""
  })
}
resource "google_compute_address" "static" {
  name = "ipv4-address"
}