locals {
    regex_valid_vpc_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$"
  // Will fail if var.vpc_cidr is invalid
  regex_vpc_cidr = regex(local.regex_valid_vpc_cidr, var.vpc_cidr) == var.vpc_cidr ? 0 : "Variable [vpc_cidr] must be a valid vpc cidr"
  
  permissions_allowed_values = [
    "None (configure later)",
    "Use existing (specify an existing IAM role name)",
    "Create with assume role permissions (specify an STS role ARN)",
    "Create with read permissions",
    "Create with read-write permissions"]
  // Will fail if var.iam_permissions is invalid
  validate_permissions = index(local.permissions_allowed_values, var.iam_permissions)

  installation_type_allowed_values = [
    "Primary Multi-Domain Server",
    "Secondary Multi-Domain Server",
    "Multi-Domain Log Server"]
  // Will fail if var.mds_installation_type is invalid
  validate_installation_type = index(local.installation_type_allowed_values, var.mds_installation_type)

  primary_mds = var.mds_installation_type == "Primary Multi-Domain Server"
  secondary_mds = var.mds_installation_type == "Secondary Multi-Domain Server"

  use_role = var.iam_permissions != "None (configure later)" && local.primary_mds ? 1 : 0
  create_iam_role = (local.primary_mds) && (var.iam_permissions == "Create with assume role permissions (specify an STS role ARN)" || var.iam_permissions == "Create with read permissions" || var.iam_permissions == "Create with read-write permissions")

  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.mds_admin_shell)

  regex_valid_key_name = "[\\S\\s]+[\\S]+"
  // will fail if var.key_name is invalid
  regex_key_name_result=regex(local.regex_valid_key_name, var.key_name) == var.key_name ? 0 : "Variable [key_name] must be a none empty string"

  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"
  // Will fail if var.admin_subnet or var.gateway_addresses are invalid
  mgmt_subnet_regex_result = regex(local.regex_valid_cidr_range, var.admin_cidr) == var.admin_cidr ? 0 : "var.admin_subnet must be a valid CIDR range"
  gw_addr_regex_result = regex(local.regex_valid_cidr_range, var.gateway_addresses) == var.gateway_addresses ? 0 : "var.gateway_addresses must be a valid CIDR range"
  volume_encryption_condition = var.volume_encryption != "" ? true : false

  regex_valid_gateway_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
  // Will fail if var.mds_hostname is invalid
  regex_gateway_hostname = regex(local.regex_valid_gateway_hostname, var.mds_hostname) == var.mds_hostname ? 0 : "Variable [mds_hostname] must be a valid hostname label or an empty string"

  regex_valid_primary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.primary_ntp is invalid
  regex_primary_ntp = regex(local.regex_valid_primary_ntp, var.primary_ntp) == var.primary_ntp ? 0 : "Variable [primary_ntp] must be a valid ntp"

  regex_valid_secondary_ntp = "^[\\.a-zA-Z0-9\\-]*$"
  // Will fail if var.secondary_ntp is invalid
  regex_secondary_ntp = regex(local.regex_valid_secondary_ntp, var.secondary_ntp) == var.secondary_ntp ? 0 : "Variable [secondary_ntp] must be a valid ntp"

  regex_valid_mds_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.mds_password_hash is invalid
  regex_mds_password_hash = regex(local.regex_valid_mds_password_hash, var.mds_password_hash) == var.mds_password_hash ? 0 : "Variable [mds_password_hash] must be a valid password hash"
  regex_maintenance_mode_password_hash = regex(local.regex_valid_mds_password_hash, var.mds_maintenance_mode_password_hash) == var.mds_maintenance_mode_password_hash ? 0 : "Variable [mds_maintenance_mode_password_hash] must be a valid password hash"

  regex_valid_sic_key = "(|[a-zA-Z0-9]{8,})"
  // Will fail if var.mds_SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.mds_SICKey) == var.mds_SICKey ? 0 : "Variable [mds_SICKey] must be at least 8 alphanumeric characters"
  //Splits the version and licence and returns the os version
  version_split = element(split("-", var.mds_version), 0)

  mds_bootstrap_script64 = base64encode(var.mds_bootstrap_script)
  mds_SICkey_base64 = base64encode(var.mds_SICKey)
  mds_password_hash_base64 =base64encode(var.mds_password_hash)
  maintenance_mode_password_hash_base64 = base64encode(var.mds_maintenance_mode_password_hash)
}