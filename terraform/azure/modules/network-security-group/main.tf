resource "azurerm_network_security_group" "nsg" {
  name = var.security_group_name
  location = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
  }

//************ Security Rule Example **************//
resource "azurerm_network_security_rule" "security_rule" {
  count = length(var.security_rules)
  name = lookup(var.security_rules[count.index], "name")
  priority = lookup(var.security_rules[count.index], "priority", 4096 - length(var.security_rules) + count.index)
  direction = lookup(var.security_rules[count.index], "direction")
  access = lookup(var.security_rules[count.index], "access")
  protocol = lookup(var.security_rules[count.index], "protocol")
  source_port_ranges = split(",", replace(lookup(var.security_rules[count.index], "source_port_ranges", "*"), "*", "0-65535"))
  destination_port_ranges = split(",", replace(lookup(var.security_rules[count.index], "destination_port_ranges", "*"), "*", "0-65535"))
  description = lookup(var.security_rules[count.index], "description")
  source_address_prefix = lookup(var.security_rules[count.index], "source_address_prefix")
  destination_address_prefix = lookup(var.security_rules[count.index], "destination_address_prefix")
  resource_group_name = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
