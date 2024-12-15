locals {
    regex_valid_vpc_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$"
  // Will fail if var.vpc_cidr is invalid
  regex_vpc_cidr = regex(local.regex_valid_vpc_cidr, var.vpc_cidr) == var.vpc_cidr ? 0 : "Variable [vpc_cidr] must be a valid vpc cidr"
  
  asg_name = format("%s%s", var.prefix != "" ? format("%s-", var.prefix) : "", var.asg_name)
  create_iam_role = var.enable_cloudwatch ? 1 : 0

  gateways_provision_address_type_allowed_values = [
    "public",
    "private"
  ]
  // Will fail if var.gateways_provision_address_type is invalid
  validate_gateways_provision_address_type = index(local.gateways_provision_address_type_allowed_values, var.gateways_provision_address_type)
  
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"
  ]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)

  regex_valid_key_name = "[\\S\\s]+[\\S]+"
  // will fail if var.key_name is invalid
  regex_key_name_result=regex(local.regex_valid_key_name, var.key_name) == var.key_name ? 0 : "Variable [key_name] must be a none empty string"
  regex_valid_gateway_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.gateway_password_hash is invalid
  regex_gateway_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_password_hash) == var.gateway_password_hash ? 0 : "Variable [gateway_password_hash] must be a valid password hash"
  regex_gateway_maintenance_mode_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_maintenance_mode_password_hash) == var.gateway_maintenance_mode_password_hash ? 0 : "Variable [gateway_maintenance_mode_password_hash] must be a valid password hash"

  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SICKey] must be at least 8 alphanumeric characters"

  proxy_elb_type_allowed_values = [
    "none",
    "internal",
    "internet-facing"
  ]
  // Will fail if var.proxy_elb_type is invalid
  validate_proxy_elb_type = index(local.proxy_elb_type_allowed_values, var.proxy_elb_type)

  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"
  // Will fail if var.proxy_elb_clients is invalid
  regex_cidr_result = regex(local.regex_valid_cidr_range, var.proxy_elb_clients) == var.proxy_elb_clients ? 0 : "Variable [proxy_elb_clients] must be a valid CIDR range"

  tags_asg_format = null_resource.tags_as_list_of_maps.*.triggers

  //Splits the version and licence and returns the os version
  version_split = element(split("-", var.gateway_version), 0)
  gateway_bootstrap_script64 = base64encode(var.gateway_bootstrap_script)
  gateway_password_hash_base64 = base64encode(var.gateway_password_hash)
  maintenance_mode_password_hash_base64 = base64encode(var.gateway_maintenance_mode_password_hash)
  gateway_SICkey_base64 = base64encode(var.gateway_SICKey)
}
resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.instances_tags))

  triggers = {
    "key" = keys(var.instances_tags)[count.index]
    "value" = values(var.instances_tags)[count.index]
    "propagate_at_launch" = "true"
  }
}