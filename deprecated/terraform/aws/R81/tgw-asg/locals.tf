locals {
  permissions_allowed_values = [
    "None (configure later)",
    "Use existing (specify an existing IAM role name)",
    "Create with assume role permissions (specify an STS role ARN)",
    "Create with read permissions",
    "Create with read-write permissions"]
  // Will fail if var.management_permissions is invalid
  validate_permissions = index(local.permissions_allowed_values, var.management_permissions)

  regex_valid_key_name = "[\\S\\s]+[\\S]+"
  // will fail if var.key_name is invalid
  regex_key_name_result=regex(local.regex_valid_key_name, var.key_name) == var.key_name ? 0 : "Variable [key_name] must be a none empty string"

  regex_valid_gateway_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SIC_Key is invalid
  regex_gateway_sic_result = regex(local.regex_valid_gateway_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SIC_Key] must be at least 8 alphanumeric characters"

  control_over_public_or_private_allowed_values = [
    "public",
    "private"]
  // will fail if [var.control_gateway_over_public_or_private_address] is invalid:
  validate_control_over_public_or_private = index(local.control_over_public_or_private_allowed_values, var.control_gateway_over_public_or_private_address)

  gateway_management_allowed_values = [
    "Locally managed",
    "Over the internet"]
  // will fail if [var.gateway_management] is invalid:
  validate_gateway_management = index(local.gateway_management_allowed_values, var.gateway_management)

  regex_valid_management_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.management_password_hash is invalid
  regex_management_password_hash = regex(local.regex_valid_management_password_hash, var.management_password_hash) == var.management_password_hash ? 0 : "Variable [management_password_hash] must be a valid password hash"
  regex_management_maintenance_mode_password_hash = regex(local.regex_valid_management_password_hash, var.management_maintenance_mode_password_hash) == var.management_maintenance_mode_password_hash ? 0 : "Variable [management_maintenance_mode_password_hash] must be a valid password hash"


  regex_valid_gateway_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.gateway_password_hash is invalid
  regex_gateway_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_password_hash) == var.gateway_password_hash ? 0 : "Variable [gateway_password_hash] must be a valid password hash"
  regex_gateway_maintenance_mode_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_maintenance_mode_password_hash) == var.gateway_maintenance_mode_password_hash ? 0 : "Variable [gateway_maintenance_mode_password_hash] must be a valid password hash"


  regex_valid_asn = "^[0-9]+$"
  // Will fail if var.asn is invalid
  regex_asn = regex(local.regex_valid_asn, var.asn) == var.asn ? 0 : "Variable [asn] must be a valid asn"

  regex_valid_admin_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$"
  // Will fail if var.admin_cidr is invalid
  regex_admin_cidr = regex(local.regex_valid_admin_cidr, var.admin_cidr) == var.admin_cidr ? 0 : "Variable [admin_cidr] must be a valid CIDR"

  regex_valid_gateways_addresses = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$"
  // Will fail if var.gateways_addresses is invalid
  regex_gateways_addresses = regex(local.regex_valid_gateways_addresses, var.gateways_addresses) == var.gateways_addresses ? 0 : "Variable [gateways_addresses] must be a valid gateways addresses"

  regex_valid_management_server = "^[0-9a-zA-Z-._]+$"
  // Will fail if var.management_server is invalid
  regex_management_server = regex(local.regex_valid_management_server, var.management_server) == var.management_server ? 0 : "Variable [management_server] can not be an empty string"

  regex_valid_configuration_template = "^[0-9a-zA-Z-._]+$"
  // Will fail if var.configuration_template is invalid
  regex_configuration_template = regex(local.regex_valid_configuration_template, var.configuration_template) == var.configuration_template ? 0 : "Variable [configuration_template] can not be an empty string"

  deploy_management_condition = var.management_deploy == true
}