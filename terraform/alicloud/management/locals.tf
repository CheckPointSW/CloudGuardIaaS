locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)

  gateway_management_allowed_values = [
    "Locally managed",
    "Over the internet"]
  // Will fail if var.gateway_management is invalid
  validate_gateway_management = index(local.gateway_management_allowed_values, var.gateway_management)

  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"
  // Will fail if var.admin_cidr or var.gateway_addresses are invalid
  mgmt_vswitch_regex_result = regex(local.regex_valid_cidr_range, var.admin_cidr) == var.admin_cidr ? 0 : "var.admin_cidr must be a valid CIDR range"
  gw_addr_regex_result = regex(local.regex_valid_cidr_range, var.gateway_addresses) == var.gateway_addresses ? 0 : "var.gateway_addresses must be a valid CIDR range"
  mgmt_old_config_values = [
    "R81-BYOL",
    "R81.10-BYOL"
  ]
  mgmt_new_config = contains(local.mgmt_old_config_values, var.version_license) ? 0 : 1
}