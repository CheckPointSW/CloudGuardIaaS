# Creation of DNS Zone
resource "azurerm_resource_group" "rg-dns-myzone" {
  name                = "rg-dns-myzone"
  location            = var.location
}
resource "azurerm_dns_zone" "mydns-public-zone" {
  name                = var.mydns-zone
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
}

# Creation of the Management Hub
resource "azurerm_resource_group" "rg-vnet-secmgmt" {
  name      = "rg-v${var.net-secmgmt}"
  location  = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-secmgmt" {
  name      = "nsg-v${var.net-secmgmt}"
  location  = azurerm_resource_group.rg-vnet-secmgmt.location
  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
}
resource "azurerm_virtual_network" "vnet-secmgmt" {
  name          = "v${var.net-secmgmt}"
  address_space = ["172.16.8.0/22"]
  location            = azurerm_resource_group.rg-vnet-secmgmt.location
  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
}
resource "azurerm_subnet" "net-secmgmt" {
  name              = var.net-secmgmt
  address_prefixes  = ["172.16.8.0/24"]
  virtual_network_name  = azurerm_virtual_network.vnet-secmgmt.name
  resource_group_name   = azurerm_resource_group.rg-vnet-secmgmt.name
  depends_on = [azurerm_virtual_network.vnet-secmgmt]
}

# Creation of the Northbound Hub
resource "azurerm_resource_group" "rg-vnet-north" {
  name      = "rg-v${var.net-north}"
  location  = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-north" {
  name                = "nsg-v${var.net-north}"
  location            = azurerm_resource_group.rg-vnet-north.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_virtual_network" "vnet-north" {
  name                = "v${var.net-north}"
  address_space       = ["172.16.0.0/22"]
  location            = azurerm_resource_group.rg-vnet-north.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_subnet" "net-north-gateways" {
  name                  = "${var.net-north}-gateways"
  address_prefixes      = ["172.16.0.0/24"]
  virtual_network_name  = azurerm_virtual_network.vnet-north.name
  resource_group_name   = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_virtual_network.vnet-north]
}

# Peering from/to Management Hub to Nouthbound Hub
resource "azurerm_virtual_network_peering" "vnet-secmgmt-to-vnet-north" {
  name = "v${var.net-secmgmt}-to-${data.azurerm_virtual_network.vnet-north-gwlb.name}"
  resource_group_name = "rg-v${var.net-secmgmt}"
  virtual_network_name = azurerm_virtual_network.vnet-secmgmt.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet-north-gwlb.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-north-gateways]
}
resource "azurerm_virtual_network_peering" "vnet-north-to-vnet-secmgmt" {
  name = "${data.azurerm_virtual_network.vnet-north-gwlb.name}-to-v${var.net-secmgmt}"
  resource_group_name = azurerm_resource_group.rg-gwlb-vmss.name
  virtual_network_name = data.azurerm_virtual_network.vnet-north-gwlb.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-north-gateways]
}

# Creation of the Spoke Num
resource "azurerm_resource_group" "rg-vnet-spoke" {
  count     = length(var.num-spoke)
  name      = "rg-v${var.net-spoke}-${count.index}"
  location  = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-spoke" {
  count     = length(var.num-spoke)
  name      = "nsg-v${var.net-spoke}-${count.index}"
  location  = var.location
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vnet-spoke]
}
resource "azurerm_virtual_network" "vnet-spoke" {
  count     = length(var.num-spoke)
  name      = "v${var.net-spoke}-${count.index}"
  location  = var.location  
  address_space = ["${lookup(var.num-spoke, count.index)[0]}/22"]
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vnet-spoke]
}
resource "azurerm_subnet" "net-spoke-0-web" {
  name  = "${var.net-spoke}-0-web"
  virtual_network_name  = "v${var.net-spoke}-0"
  resource_group_name   = "rg-v${var.net-spoke}-0"
  address_prefixes      = ["${lookup(var.num-spoke, 0)[0]}/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  depends_on = [azurerm_virtual_network.vnet-spoke]
}
resource "azurerm_subnet" "net-spoke-1-web" {
  name  = "${var.net-spoke}-1-web"
  virtual_network_name  = "v${var.net-spoke}-1"
  resource_group_name   = "rg-v${var.net-spoke}-1"
  address_prefixes      = ["${lookup(var.num-spoke, 1)[0]}/24"]

  depends_on = [azurerm_virtual_network.vnet-spoke]
}
resource "azurerm_subnet" "net-spoke-db" {
  count = length(var.num-spoke)
  name  = "${var.net-spoke}-${count.index}-db"

  virtual_network_name  = "v${var.net-spoke}-${count.index}"
  resource_group_name   = "rg-v${var.net-spoke}-${count.index}"
  address_prefixes      = ["${lookup(var.num-spoke, count.index)[1]}/24"]
  depends_on = [azurerm_virtual_network.vnet-spoke]
}
# Routing Tables for Spoke
locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = ["VirtualNetworkGateway","VnetLocal","Internet","VirtualAppliance","None"]
}
 resource "azurerm_route_table" "rt-vnet-spoke" {
  count = length(var.num-spoke)
  name = "rt-v${var.net-spoke}-${count.index}"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vnet-spoke]

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[2]
  #  next_hop_type = local.next_hop_type_allowed_values[3]
  #  next_hop_in_ip_address = var.spokes-default-gateway
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-spoke[count.index].address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
  route {
    name = "route-to-internal-networks"
    address_prefix = "10.0.0.0/16"
    next_hop_type = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = var.spokes-default-gateway
  }
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-db" {
  count = length(var.num-spoke)
  subnet_id = azurerm_subnet.net-spoke-db[count.index].id
  route_table_id = azurerm_route_table.rt-vnet-spoke[count.index].id
  depends_on = [azurerm_subnet.net-spoke-db,azurerm_route_table.rt-vnet-spoke]
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-0-web" {
  subnet_id = azurerm_subnet.net-spoke-0-web.id
  route_table_id = azurerm_route_table.rt-vnet-spoke[0].id
  depends_on = [azurerm_subnet.net-spoke-0-web,azurerm_route_table.rt-vnet-spoke]
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-1-web" {
  subnet_id = azurerm_subnet.net-spoke-1-web.id
  route_table_id = azurerm_route_table.rt-vnet-spoke[1].id
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_route_table.rt-vnet-spoke]
}

# Creation of the Southbound Hub
resource "azurerm_resource_group" "rg-vnet-south" {
  name = "rg-v${var.net-south}"
  location = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-south" {
  name = "nsg-v${var.net-south}"
  location = var.location
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_resource_group.rg-vnet-south]
}
resource "azurerm_virtual_network" "vnet-south" {
  name = "v${var.net-south}"
  address_space = ["172.16.4.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-south}"
  tags = {
    environment = "south"
  }
  depends_on = [azurerm_resource_group.rg-vnet-south]
}
resource "azurerm_subnet" "net-south-frontend" {
  name = "${var.net-south}-frontend"
  address_prefixes = ["172.16.4.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_virtual_network.vnet-south]
}
resource "azurerm_subnet" "net-south-backend" {
  name = "${var.net-south}-backend"
  address_prefixes = ["172.16.5.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_virtual_network.vnet-south]
}
# Peering from/to Management Hub to Southbound Hub
resource "azurerm_virtual_network_peering" "vnet-secmgmt-to-vnet-south" {
  name = "v${var.net-secmgmt}-to-v${var.net-south}"
  resource_group_name = "rg-v${var.net-secmgmt}"
  virtual_network_name = "v${var.net-secmgmt}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-secmgmt" {
  name = "v${var.net-south}-to-v${var.net-secmgmt}"
  resource_group_name = "rg-v${var.net-south}"
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
# Peering from/to spoke to south
resource "azurerm_virtual_network_peering" "vnet-spoke-to-vnet-south" {
  count = length(var.num-spoke)
  name = "v${var.net-spoke}-${count.index}-to-v${var.net-south}"
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  virtual_network_name = "v${var.net-spoke}-${count.index}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-spoke" {
  count = length(var.num-spoke)
  name = "v${var.net-south}-to-v${var.net-spoke}-${count.index}"
  resource_group_name = "rg-v${var.net-south}"
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
}