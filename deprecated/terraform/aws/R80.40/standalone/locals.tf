locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)

  enable_cloudwatch_policy = var.enable_cloudwatch ? 1 : 0

  regex_valid_key_name = "[\\S\\s]+[\\S]+"
  // will fail if var.key_name is invalid
  regex_key_name_result=regex(local.regex_valid_key_name, var.key_name) == var.key_name ? 0 : "Variable [key_name] must be a none empty string"

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

  regex_valid_standalone_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.standalone_password_hash is invalid
  regex_standalone_password_hash = regex(local.regex_valid_standalone_password_hash, var.standalone_password_hash) == var.standalone_password_hash ? 0 : "Variable [standalone_password_hash] must be a valid password hash"
  regex_maintenance_mode_password_hash = regex(local.regex_valid_standalone_password_hash, var.standalone_maintenance_mode_password_hash) == var.standalone_maintenance_mode_password_hash ? 0 : "Variable [standalone_maintenance_mode_password_hash] must be a valid password hash"

  //Splits the version and licence and returns the os version
  version_split = element(split("-", var.standalone_version), 0)

  standalone_bootstrap_script64 = base64encode(var.standalone_bootstrap_script)
  standalone_password_hash_base64 = base64encode(var.standalone_password_hash)
  maintenance_mode_password_hash_base64 = base64encode(var.standalone_maintenance_mode_password_hash)
}