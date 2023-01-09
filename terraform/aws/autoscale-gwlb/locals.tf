locals {
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

  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SICKey] must be at least 8 alphanumeric characters"




  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"

  tags_asg_format = null_resource.tags_as_list_of_maps.*.triggers

  //Splits the version and licence and returns the os version
  version_split = element(split("-", var.gateway_version), 0)

  gateway_bootstrap_script64 = base64encode(var.gateway_bootstrap_script)
  gateway_SICkey_base64 = base64encode(var.gateway_SICKey)
  gateway_password_hash_base64 = base64encode(var.gateway_password_hash)

  is_gwlb_ami = length(regexall(".*R80.40.*", var.gateway_version)) > 0

}
resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.instances_tags))

  triggers = {
    "key" = keys(var.instances_tags)[count.index]
    "value" = values(var.instances_tags)[count.index]
    "propagate_at_launch" = "true"
  }
}
