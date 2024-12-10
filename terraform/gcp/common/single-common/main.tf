locals {
  disk_type_condition = var.disk_type == "SSD Persistent Disk" ? "pd-ssd" : var.disk_type == "Standard Persistent Disk" ? "pd-standard" : ""
  admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
}

resource "random_string" "random_string" {
  length = 5
  special = false
  upper = false
  keepers = {}
}

resource "random_string" "generated_password" {
  length = 12
  special = false
}
resource "google_compute_address" "static" {
  name = "ipv4-address-${random_string.random_string.result}"
}
resource "google_compute_instance" "gateway" {
  name = "${var.prefix}-${random_string.random_string.result}"
  description = "Check Point Security ${replace(var.installation_type,"(Standalone)","--")==var.installation_type?split(" ",var.installation_type)[0]:" Gateway and Management"}"
  zone = var.zone
  labels = {goog-dm = "${var.prefix}-${random_string.random_string.result}"}
  tags =replace(var.installation_type,"(Standalone)","--")==var.installation_type?[
    "checkpoint-${split(" ",lower(var.installation_type))[0]}","${var.prefix}${random_string.random_string.result}"
  ]:["checkpoint-gateway","checkpoint-management","${var.prefix}${random_string.random_string.result}"]
  machine_type = var.machine_type
  can_ip_forward = var.installation_type == "Management only"? false:true
  boot_disk {
    auto_delete = true
    device_name = "chkp-single-boot-${random_string.random_string.result}"
    initialize_params {
      size = var.disk_size
      type = local.disk_type_condition
      image = "checkpoint-public/${var.image_name}"
    }
  }
  network_interface {
    network = var.network[0]
    subnetwork = var.subnetwork[0]
    dynamic "access_config" {
      for_each = var.external_ip == "none"? []:[1]
      content {
        nat_ip = var.external_ip=="static" ? google_compute_address.static.address : null
      }
    }

  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks >= 1 ? [
      1] : []
    content {
      network = var.internal_network1_network[0]
      subnetwork = var.internal_network1_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks >= 2 ? [
      1] : []
    content {
      network = var.internal_network2_network[0]
      subnetwork = var.internal_network2_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks >= 3 ? [
      1] : []
    content {
      network = var.internal_network3_network[0]
      subnetwork = var.internal_network3_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks >= 4 ? [
      1] : []
    content {
      network = var.internal_network4_network[0]
      subnetwork = var.internal_network4_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks >= 5 ? [
      1] : []
    content {
      network = var.internal_network5_network[0]
      subnetwork = var.internal_network5_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks == 6 ? [
      1] : []
    content {
      network = var.internal_network6_network[0]
      subnetwork = var.internal_network6_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks == 7 ? [
      1] : []
    content {
      network = var.internal_network7_network[0]
      subnetwork = var.internal_network7_subnetwork[0]
    }
  }
  dynamic "network_interface" {
    for_each = var.num_additional_networks == 8 ? [
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
    adminPasswordSourceMetadata = var.generate_password ?random_string.generated_password.result : ""
  } : {adminPasswordSourceMetadata = var.generate_password?random_string.generated_password.result : ""}

  metadata_startup_script = templatefile("${path.module}/../startup-script.sh", {
    // script's arguments
    generatePassword = var.generate_password
    config_url = "https://runtimeconfig.googleapis.com/v1beta1/projects/${var.project}/configs/-config"
    config_path = "projects/${var.project}/configs/-config"
    sicKey = ""
    allowUploadDownload = var.allow_upload_download
    templateName = "single_tf"
    templateVersion = "20230910"
    templateType = "terraform"
    hasInternet = "true"
    enableMonitoring = var.enable_monitoring
    shell = var.admin_shell
    installation_type = var.installation_type
    computed_sic_key = var.sic_key
    managementGUIClientNetwork = var.management_gui_client_network
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
    os_version = var.os_version
    maintenance_mode_password_hash = var.maintenance_mode_password_hash
  })
}