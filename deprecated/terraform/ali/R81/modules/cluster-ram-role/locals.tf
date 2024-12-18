locals {
  ram_role_name = format("%s-ram-role-%s", var.gateway_name, random_id.ram_uuid.hex)
  ram_policy_name = format("%s-ram-policy-%s", var.gateway_name, random_id.ram_uuid.hex)

}