resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  location = var.location
  address_space = [var.address_space]
  resource_group_name = var.resource_group_name
  dns_servers = var.dns_servers
  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  depends_on = [azurerm_virtual_network.vnet]
  count = length(var.subnet_names)
  name = var.subnet_names[count.index]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = var.resource_group_name
  address_prefix = var.subnet_prefixes[count.index]
  network_security_group_id = count.index == 0 ? var.nsg_id : ""
}

locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = [
    "VirtualNetworkGateway",
    "VnetLocal",
    "Internet",
    "VirtualAppliance",
    "None"
  ]
}

resource "azurerm_route_table" "frontend" {
  name = azurerm_subnet.subnet[0].name
  location = var.location
  resource_group_name = var.resource_group_name

  route {
    name = "Local-Subnet"
    address_prefix = azurerm_subnet.subnet[0].address_prefix
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
  route {
    name = "To-Internal"
    address_prefix = var.address_space
    next_hop_type = local.next_hop_type_allowed_values[4]
  }
}

resource "azurerm_subnet_route_table_association" "frontend_association" {
  subnet_id = azurerm_subnet.subnet[0].id
  route_table_id = azurerm_route_table.frontend.id
}

resource "azurerm_route_table" "backend" {
  name = azurerm_subnet.subnet[1].name
  location = var.location
  resource_group_name = var.resource_group_name

  route {
    name = "To-Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[4]
  }
}

resource "azurerm_subnet_route_table_association" "backend_association" {
  subnet_id = azurerm_subnet.subnet[1].id
  route_table_id = azurerm_route_table.backend.id
}
