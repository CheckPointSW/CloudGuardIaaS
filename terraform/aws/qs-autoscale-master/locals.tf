locals {
  regex_valid_vpc_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-8]))$"
  // Will fail if var.vpc_cidr is invalid
  regex_vpc_cidr = regex(local.regex_valid_vpc_cidr, var.vpc_cidr) == var.vpc_cidr ? 0 : "Variable [vpc_cidr] must be a valid vpc cidr"

  regex_valid_provision_tag = "^[a-zA-Z0-9-]{1,12}$"
  // Will fail if var.provision_tag is invalid
  regex_provision_tag = regex(local.regex_valid_provision_tag, var.provision_tag) == var.provision_tag ? 0 : "Variable [provision_tag] must be up to 12 alphanumeric characters and unique for each Quick Start deployment"

  load_balancers_type_allowed_values = [
    "Network Load Balancer",
    "Application Load Balancer"]
  // Will fail if var.load_balancers_type is invalid
  validate_load_balancers_type = index(local.load_balancers_type_allowed_values, var.load_balancers_type)

  lb_protocol_allowed_values = var.load_balancers_type == "Network Load Balancer" ? [
    "TCP",
    "TLS",
    "UDP",
    "TCP_UDP"] : [
    "HTTP",
    "HTTPS"]
  // Will fail if var.load_balancer_protocol is invalid
  validate_lb_protocol = index(local.lb_protocol_allowed_values, var.load_balancer_protocol)

  regex_valid_certificate = "^(arn:aws:[a-z]+::[0-9]{12}:server-certificate/[a-zA-Z0-9-]*)?$"
  // Will fail if var.certificate is invalid
  regex_certificate = regex(local.regex_valid_certificate, var.certificate) == var.certificate ? 0 : "Variable [certificate] must be a valid Amazon Resource Name (ARN), for example: arn:aws:iam::123456789012:server-certificate/web-server-certificate"

  regex_valid_service_port = "^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])?$"
  // Will fail if var.service_port is invalid
  regex_service_port = regex(local.regex_valid_service_port, var.service_port) == var.service_port ? 0 : "Custom service port must be a number between 0 and 65535"

  regex_valid_gateway_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.gateway_password_hash is invalid
  regex_gateway_password_hash = regex(local.regex_valid_gateway_password_hash, var.gateway_password_hash) == var.gateway_password_hash ? 0 : "Variable [gateway_password_hash] must be a valid password hash."

  regex_valid_gateway_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.gateway_SIC_Key is invalid
  regex_gateway_sic_result = regex(local.regex_valid_gateway_sic_key, var.gateway_SICKey) == var.gateway_SICKey ? 0 : "Variable [gateway_SIC_Key] must be at least 8 alphanumeric characters."

  regex_valid_management_password_hash = "^[\\$\\./a-zA-Z0-9]*$"
  // Will fail if var.gateway_password_hash is invalid
  regex_management_password_hash = regex(local.regex_valid_management_password_hash, var.management_password_hash) == var.management_password_hash ? 0 : "Variable [management_password_hash] must be a valid password hash."

  regex_valid_admin_cidr = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$"
  // Will fail if var.admin_cidr is invalid
  regex_admin_cidr = regex(local.regex_valid_admin_cidr, var.admin_cidr) == var.admin_cidr ? 0 : "Variable [admin_cidr] must be a valid CIDR."

  regex_valid_gateways_addresses = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$"
  // Will fail if var.gateways_addresses is invalid
  regex_gateways_addresses = regex(local.regex_valid_gateways_addresses, var.gateways_addresses) == var.gateways_addresses ? 0 : "Variable [gateways_addresses] must be a valid gateways addresses."


  regex_valid_server_ami = "^(ami-(([0-9a-f]{8})|([0-9a-f]{17})))?$"
  // Will fail if var.server_ami is invalid
  regex_server_ami = regex(local.regex_valid_server_ami, var.server_ami) == var.server_ami ? 0 : "Amazon Machine Image ID must be in the form ami-xxxxxxxx or ami-xxxxxxxxxxxxxxxxx"
}