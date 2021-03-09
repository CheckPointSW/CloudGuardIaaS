locals {
  permissions_allowed_values = [
    "None (configure later)",
    "Use existing (specify an existing IAM role name)",
    "Create with assume role permissions (specify an STS role ARN)",
    "Create with read permissions",
    "Create with read-write permissions"]
  // Will fail if var.permissions is invalid
  validate_permissions = index(local.permissions_allowed_values, var.iam_permissions)

  use_role = var.iam_permissions == "None (configure later)" ? 0 : 1
  create_iam_role = var.iam_permissions == "Create with assume role permissions (specify an STS role ARN)" || var.iam_permissions == "Create with read permissions" || var.iam_permissions == "Create with read-write permissions"

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
  // Will fail if var.admin_subnet or var.gateway_addresses are invalid
  mgmt_subnet_regex_result = regex(local.regex_valid_cidr_range, var.admin_cidr) == var.admin_cidr ? 0 : "var.admin_subnet must be a valid CIDR range"
  gw_addr_regex_result = regex(local.regex_valid_cidr_range, var.gateway_addresses) == var.gateway_addresses ? 0 : "var.gateway_addresses must be a valid CIDR range"
  volume_encryption_condition = var.volume_encryption != "" ? true : false

  regex_valid_primary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.primary_ntp is invalid
  regex_primary_ntp = regex(local.regex_valid_primary_ntp, var.primary_ntp) == var.primary_ntp ? 0 : "Variable [primary_ntp] must be a valid ntp"

  regex_valid_secondary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.secondary_ntp is invalid
  regex_secondary_ntp = regex(local.regex_valid_secondary_ntp, var.secondary_ntp) == var.secondary_ntp ? 0 : "Variable [secondary_ntp] must be a valid ntp"

  regex_valid_management_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.management_password_hash is invalid
  regex_management_password_hash = regex(local.regex_valid_management_password_hash, var.management_password_hash) == var.management_password_hash ? 0 : "Variable [management_password_hash] must be a valid password hash"

  regex_valid_sic_key = "(|[a-zA-Z0-9]{8,})"
  // Will fail if var.SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.SICKey) == var.SICKey ? 0 : "Variable [SICKey] must be at least 8 alphanumeric characters"
}