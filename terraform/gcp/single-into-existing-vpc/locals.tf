locals {
  license_allowed_values = [
    "BYOL",
    "PAYG"]
  // will fail if [var.license] is invalid:
  validate_license = index(local.license_allowed_values, upper(var.license))

  split_image_name = split("-", var.image_name)
  // will fail if the image license name is unmatched to var.license:
  validate_image_name =index(local.split_image_name, lower(var.license)) >=0 && (index(local.split_image_name, "single") >=0 || ((replace(var.image_name,"cluster" ,"smth") == var.image_name)&&replace(var.image_name,"MIG" ,"smth") == var.image_name)) ? 0 : index(local.split_image_name,"INVALID IMAGE NAME")
  regex_valid_admin_SSH_key = "^(^$|ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3})"
  // Will fail if var.admin_SSH_key is invalid
  regex_admin_SSH_key = regex(local.regex_valid_admin_SSH_key, var.admin_SSH_key) == var.admin_SSH_key ? 0 : "Please enter a valid SSH public key or leave empty"
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)
  disk_type_allowed_values = [
    "SSD Persistent Disk",
    "Balanced Persistent Disk",
    "Standard Persistent Disk"]
  // Will fail if var.disk_type is invalid
  validate_disk_type = index(local.disk_type_allowed_values, var.diskType)
  adminPasswordSourceMetadata = var.generatePassword ?random_string.generated_password.result : ""
  disk_type_condition = var.diskType == "SSD Persistent Disk" ? "pd-ssd" : var.diskType == "Balanced Persistent Disk" ? "pd-balanced" : var.diskType == "Standard Persistent Disk" ? "pd-standard" : ""
  admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
  ICMP_traffic_condition = length(var.network_icmpSourceRanges	) == 0 ? 0 : 1
  TCP_traffic_condition = length(var.network_tcpSourceRanges) == 0 ? 0 : 1
  UDP_traffic_condition = length(var.network_udpSourceRanges	) == 0 ? 0 : 1
  SCTP_traffic_condition = length(var.network_sctpSourceRanges) == 0 ? 0 : 1
  ESP_traffic_condition = length(var.network_espSourceRanges) == 0 ? 0 : 1
}