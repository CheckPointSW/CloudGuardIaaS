locals {
  license_allowed_values = [
    "BYOL",
    "PAYG"]
  // will fail if [var.license] is invalid:
  validate_license = index(local.license_allowed_values, upper(var.license))

  regex_validate_image_name = "check-point-r8[0-1][1-4]0-gw-(byol|payg)-mig-[0-9]{3}-([0-9]{3}|[a-z]+)-v[0-9]{8,}"
  // will fail if the image name is not in the right syntax
  validate_image_name = length(regexall(local.regex_validate_image_name, var.image_name)) > 0 ? 0 : index(split("-", var.image_name), "INVALID IMAGE NAME")

  management_nic_allowed_values = [
    "Ephemeral Public IP (eth0)",
    "Private IP (eth1)"]
  // will fail if [var.management_nic] is invalid:
  validate_management_nic = index(local.management_nic_allowed_values, var.management_nic)

  regex_valid_management_name = "^([ -~]+)$"
  // Will fail if var.management_name is invalid
  regex_management_name = regex(local.regex_valid_management_name, var.management_name) == var.management_name ? 0 : "Variable [management_name] must be a valid Security Management name including ascii characters only"

  regex_valid_configuration_template_name = "^([ -~]+)$"
  // Will fail if var.configuration_template_name is invalid
  regex_configuration_template_name = regex(local.regex_valid_configuration_template_name, var.configuration_template_name) == var.configuration_template_name ? 0 : "Variable [configuration_template_name] must be a valid autoprovisioing configuration template name including ascii characters only"

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

  regions_allowed_values = data.google_compute_regions.available_regions.names
  // Will fail if var.region is invalid
  validate_region = index(local.regions_allowed_values, var.region)

  disk_type_allowed_values = [
    "SSD Persistent Disk",
    "Balanced Persistent Disk",
    "Standard Persistent Disk"]
  // Will fail if var.disk_type is invalid
  validate_disk_type = index(local.disk_type_allowed_values, var.disk_type)



  disk_type_condition = var.disk_type == "SSD Persistent Disk" ? "pd-ssd" : var.disk_type == "Balanced Persistent Disk" ? "pd-balanced" : var.disk_type == "Standard Persistent Disk" ? "pd-standard" : ""
  mgmt_nic_condition = var.management_nic == "Ephemeral Public IP (eth0)" ? true : false
  mgmt_nic_ip_address_condition = local.mgmt_nic_condition ? "x-chkp-ip-address--public" : "x-chkp-ip-address--private"
  mgmt_nic_interface_condition = local.mgmt_nic_condition ? "x-chkp-management-interface--eth0" : "x-chkp-management-interface--eth1"
  network_defined_by_routes_condition = var.network_defined_by_routes ? "x-chkp-topology-eth1--internal" : ""
  network_defined_by_routes_settings_condition = var.network_defined_by_routes ? "x-chkp-topology-settings-eth1--network-defined-by-routes" : ""
  admin_SSH_key_condition = var.admin_SSH_key != "" ? true : false
  ICMP_traffic_condition = length(var.ICMP_traffic) == 0 ? 0 : 1
  TCP_traffic_condition = length(var.TCP_traffic) == 0 ? 0 : 1
  UDP_traffic_condition = length(var.UDP_traffic) == 0 ? 0 : 1
  SCTP_traffic_condition = length(var.SCTP_traffic) == 0 ? 0 : 1
  ESP_traffic_condition = length(var.ESP_traffic) == 0 ? 0 : 1
}