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

  regex_token_valid = "(^https://(.+).checkpoint.com/app/maas/api/v1/tenant(.+)|^$)"
  //TokenA: will fail if decode token should contain https:// and .checkpoint.com/app/maas/api/v1/tenant or empty string
  split_tokenA = split(" ", var.memberAToken)
  tokenA_decode = base64decode(element(local.split_tokenA, length(local.split_tokenA)-1))
  regex_tokenA = regex(local.regex_token_valid, local.tokenA_decode) == local.tokenA_decode  ? 0 : "Smart-1 Cloud token A is invalid format"

  //TokenB: will fail if decode token should contain https:// and .checkpoint.com/app/maas/api/v1/tenant or empty string
  split_tokenB = split(" ", var.memberBToken)
  tokenB_decode = base64decode(element(local.split_tokenB, length(local.split_tokenB)-1))
  regex_tokenB = regex(local.regex_token_valid, local.tokenB_decode) == local.tokenB_decode  ? 0 : "Smart-1 Cloud token B is invalid format"

  is_both_tokens_used = length(var.memberAToken) > 0 == length(var.memberBToken) > 0
  validation_message_both = "Smart-1 Cloud Tokens for member A and member B can not be empty."
  //Will fail if var.memberAToken is empty and var.memberBToken isn't and vice versa
  regex_s1c_validate = regex("^$", (local.is_both_tokens_used ? "" : local.validation_message_both))

  is_tokens_used = length(var.memberAToken) > 0
  is_both_tokens_the_same = var.memberAToken == var.memberBToken
  validation_message_unique = "The same Smart-1 Cloud token is used for the two Cluster members. Each Cluster member must have a unique token"
  //Will fail if both s1c tokens are the same
  regex_s1c_unique = local.is_tokens_used ? regex("^$", (local.is_both_tokens_the_same ? local.validation_message_unique : "")) : ""

  regex_valid_gateway_hostname = "^([A-Za-z]([-0-9A-Za-z]{0,61}[0-9A-Za-z])?|)$"
  // Will fail if var.gateway_hostname is invalid
  regex_gateway_hostname = regex(local.regex_valid_gateway_hostname, var.gateway_hostname) == var.gateway_hostname ? 0 : "Variable [gateway_hostname] must be a valid hostname label or an empty string"

  // Create RAM Role only if input variable ram_role_name was not provided
  create_ram_role = var.ram_role_name == "" ? 1 : 0
  version_split = element(split("-", var.gateway_version), 0)
  gateway_bootstrap_script64 = base64encode(var.gateway_bootstrap_script)
  gateway_SICkey_base64 = base64encode(var.gateway_SICKey)
  gateway_password_hash_base64 = base64encode(var.gateway_password_hash)
}