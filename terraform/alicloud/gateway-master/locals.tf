locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)

  regex_valid_gateway_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SIC_Key is invalid
  regex_gateway_sic_result = regex(local.regex_valid_gateway_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SIC_Key] must be at least 8 alphanumeric characters"

  regex_valid_gateway_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
  // Will fail if var.gateway_hostname is invalid
  regex_gateway_hostname = regex(local.regex_valid_gateway_hostname, var.gateway_hostname) == var.gateway_hostname ? 0 : "Variable [gateway_hostname] must be a valid hostname label or an empty string"
}