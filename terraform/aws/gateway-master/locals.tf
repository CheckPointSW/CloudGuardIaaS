locals {
  regex_valid_vpc_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$"
  // Will fail if var.vpc_cidr is invalid
  regex_vpc_cidr = regex(local.regex_valid_vpc_cidr, var.vpc_cidr) == var.vpc_cidr ? 0 : "Variable [vpc_cidr] must be a valid vpc cidr"

  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)

  regex_valid_key_name = "[\\S\\s]+[\\S]+"
  // will fail if var.key_name is invalid
  regex_key_name_result=regex(local.regex_valid_key_name, var.key_name) == var.key_name ? 0 : "Variable [key_name] must be a none empty string"

  regex_valid_gateway_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SIC_Key is invalid
  regex_gateway_sic_result = regex(local.regex_valid_gateway_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SIC_Key] must be at least 8 alphanumeric characters."

  regex_valid_gateway_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
  // Will fail if var.gateway_hostname is invalid
  regex_gateway_hostname = regex(local.regex_valid_gateway_hostname, var.gateway_hostname) == var.gateway_hostname ? 0 : "Variable [gateway_hostname] must be a valid hostname label or an empty string"

  regex_valid_gateway_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.gateway_password_hash is invalid
  regex_gateway_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_password_hash) == var.gateway_password_hash ? 0 : "Variable [gateway_password_hash] must be a valid password hash"
  regex_gateway_maintenance_mode_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_maintenance_mode_password_hash) == var.gateway_maintenance_mode_password_hash ? 0 : "Variable [gateway_maintenance_mode_password_hash] must be a valid password hash"

  control_over_public_or_private_allowed_values = [
    "public",
    "private"]
  // will fail if [var.control_gateway_over_public_or_private_address] is invalid:
  validate_control_over_public_or_private = index(local.control_over_public_or_private_allowed_values, var.control_gateway_over_public_or_private_address)

  regex_valid_primary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.primary_ntp is invalid
  regex_primary_ntp = regex(local.regex_valid_primary_ntp, var.primary_ntp) == var.primary_ntp ? 0 : "Variable [primary_ntp] must be a valid ntp"

  regex_valid_secondary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.secondary_ntp is invalid
  regex_secondary_ntp = regex(local.regex_valid_secondary_ntp, var.secondary_ntp) == var.secondary_ntp ? 0 : "Variable [secondary_ntp] must be a valid ntp"

  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SICKey] must be at least 8 alphanumeric characters"
}