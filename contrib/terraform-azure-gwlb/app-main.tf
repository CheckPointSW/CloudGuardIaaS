# Accept the agreement for the mgmt-byol for vmspoke image
resource "azurerm_marketplace_agreement" "vmspoke-agreement" {
  count = var.vmspoke-sku-enabled ? 0 : 1
  publisher = var.vmspoke-publisher
  offer = var.vmspoke-offer
  plan = var.vmspoke-sku
}

resource "azurerm_resource_group" "rg-app-A" {
  name     = "rg-${var.app-name-con}"
  location = var.location
}
resource "azurerm_public_ip" "publicip-app-A" {
  name                = "pub-${var.app-name-con}"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg-app-A.location
  resource_group_name = azurerm_resource_group.rg-app-A.name
  allocation_method   = "Static"
  domain_name_label   = "pub-${var.app-name-con}-${var.mgmt-dns-suffix}"
}
resource "azurerm_lb" "lb-app-A" {
  name                = "lb-${var.app-name-con}"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg-app-A.location
  resource_group_name = azurerm_resource_group.rg-app-A.name
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip-app-A.id
    gateway_load_balancer_frontend_ip_configuration_id = data.azurerm_lb.gateway-lb.frontend_ip_configuration.0.id
  }
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-gwlb]
}
resource "azurerm_lb_backend_address_pool" "lb-backend-pool" {
  loadbalancer_id = azurerm_lb.lb-app-A.id
  name            = "BackEndAddressPool"
  depends_on = [azurerm_lb.lb-app-A]
}
resource "azurerm_lb_backend_address_pool_address" "lb-backend-pool-addr" {
  name                    = "BackEndAddressPoolAddr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend-pool.id
  virtual_network_id      = azurerm_virtual_network.vnet-spoke[0].id
  ip_address              = "10.0.0.4"
  depends_on = [azurerm_lb_backend_address_pool.lb-backend-pool]
}
resource "azurerm_lb_probe" "lb-backend-probe" {
  resource_group_name = azurerm_resource_group.rg-app-A.name
  loadbalancer_id     = azurerm_lb.lb-app-A.id
  name                = "http-running-probe"
  port                = 3000

  depends_on = [azurerm_lb.lb-app-A]
}

resource "azurerm_lb_rule" "lb-rule-3000" {
  resource_group_name            = azurerm_resource_group.rg-app-A.name
  loadbalancer_id                = azurerm_lb.lb-app-A.id
  name                           = "LBRule3000"
  protocol                       = "Tcp"
  frontend_port                  = 3000
  backend_port                   = 3000
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend-pool.id]
  probe_id                       = azurerm_lb_probe.lb-backend-probe.id

  depends_on = [azurerm_lb.lb-app-A]
}
resource "azurerm_lb_rule" "lb-rule-80" {
  resource_group_name            = azurerm_resource_group.rg-app-A.name
  loadbalancer_id                = azurerm_lb.lb-app-A.id
  name                           = "LBRule80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend-pool.id]
  probe_id                       = azurerm_lb_probe.lb-backend-probe.id

  depends_on = [azurerm_lb.lb-app-A]
}

resource "azurerm_network_profile" "profile-app-juiceshop" {
  name                = "net-profile-juiceshop-${var.app-name-con}"
  location            = azurerm_resource_group.rg-app-A.location
  resource_group_name = azurerm_resource_group.rg-app-A.name

  container_network_interface {
    name = "container-nic-${var.app-name-con}"

    ip_configuration {
      name      = "nic-ipconfig-${var.app-name-con}"
      subnet_id = azurerm_subnet.net-spoke-0-web.id
    }
  }
  depends_on = [azurerm_subnet.net-spoke-0-web]
}

resource "azurerm_container_group" "container-app-juiceshop" {
  name                = "juiceshop-${var.app-name-con}"
  location            = azurerm_resource_group.rg-app-A.location
  resource_group_name = azurerm_resource_group.rg-app-A.name
  os_type             = "Linux"
  ip_address_type     = "private"
  network_profile_id  = azurerm_network_profile.profile-app-juiceshop.id

  container {
    name   = "juiceshop${var.app-name-con}"
    image  = "${var.docker-image}:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }
    ports {
      port     = 80
      protocol = "TCP"
    }    
  }
  depends_on = [azurerm_network_profile.profile-app-juiceshop]
} 

# Building the second app
resource "azurerm_resource_group" "rg-app-B" {
  name     = "rg-${var.app-name-vm}"
  location = var.location
}
resource "azurerm_public_ip" "publicip-app-B" {
  name                = "pub-${var.app-name-vm}"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg-app-B.location
  resource_group_name = azurerm_resource_group.rg-app-B.name
  allocation_method   = "Static"
  domain_name_label   = "pub-${var.app-name-vm}-${var.mgmt-dns-suffix}"
}
resource "azurerm_lb" "lb-app-B" {
  name                = "lb-${var.app-name-vm}"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg-app-B.location
  resource_group_name = azurerm_resource_group.rg-app-B.name
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip-app-B.id
    gateway_load_balancer_frontend_ip_configuration_id = data.azurerm_lb.gateway-lb.frontend_ip_configuration.0.id
  }
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-gwlb]
}
resource "azurerm_lb_backend_address_pool" "lb-backend-pool-B" {
  loadbalancer_id = azurerm_lb.lb-app-B.id
  name            = "BackEndAddressPool"
  depends_on = [azurerm_lb.lb-app-B]
}
resource "azurerm_lb_backend_address_pool_address" "lb-backend-pool-B-addr" {
  name                    = "BackEndAddressPoolAddr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend-pool-B.id
  virtual_network_id      = azurerm_virtual_network.vnet-spoke[1].id
  ip_address              = "10.0.4.4"
  depends_on = [azurerm_lb_backend_address_pool.lb-backend-pool-B]
}
resource "azurerm_lb_probe" "lb-backend-probe-B" {
  resource_group_name = azurerm_resource_group.rg-app-B.name
  loadbalancer_id     = azurerm_lb.lb-app-B.id
  name                = "http-running-probe"
  port                = 80

  depends_on = [azurerm_lb.lb-app-B]
}

resource "azurerm_lb_rule" "lb-rule-B-80" {
  resource_group_name            = azurerm_resource_group.rg-app-B.name
  loadbalancer_id                = azurerm_lb.lb-app-B.id
  name                           = "LBRule80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend-pool-B.id]
  probe_id                       = azurerm_lb_probe.lb-backend-probe-B.id

  depends_on = [azurerm_lb.lb-app-B]
}

# VM-Spoke Network interface
resource "azurerm_network_interface" "nic-vmspoke" {
    name = "${var.app-name-vm}-eth0"
    location = azurerm_resource_group.rg-app-B.location
    resource_group_name = azurerm_resource_group.rg-app-B.name
    enable_ip_forwarding = "false"
    
	ip_configuration {
      name = "${var.app-name-vm}-eth0-config"
      subnet_id = azurerm_subnet.net-spoke-1-web.id
      private_ip_address_allocation = "Dynamic"
      primary = true
    }
    depends_on = [azurerm_subnet.net-spoke-1-web]
}

# Create NSG for the vmspoke
resource "azurerm_network_security_group" "nsg-vmspoke" {
  name = "nsg-vmspoke"
  location = azurerm_resource_group.rg-app-B.location
  resource_group_name = azurerm_resource_group.rg-app-B.name
}

# Create the NSG rules for the vmspoke
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-http-s" {
  priority = 110
  name = "http-s-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = ["80","443"]
  source_address_prefix  = "*"
  destination_address_prefix = "*"
  resource_group_name  = azurerm_resource_group.rg-app-B.name
  network_security_group_name = azurerm_network_security_group.nsg-vmspoke.name
  depends_on = [azurerm_network_security_group.nsg-vmspoke]
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-vmspoke" {
  network_interface_id      = azurerm_network_interface.nic-vmspoke.id
  network_security_group_id = azurerm_network_security_group.nsg-vmspoke.id
  depends_on = [azurerm_network_interface.nic-vmspoke,azurerm_network_security_group.nsg-vmspoke]
}


# Accept the agreement for the mgmt-byol for vmspoke image
resource "azurerm_marketplace_agreement" "vmspoke-agreement" {
  count = var.vmspoke-sku-enabled ? 0 : 1
  publisher = var.vmspoke-publisher
  offer = var.vmspoke-offer
  plan = var.vmspoke-sku
}

# VM-Spoke Virtual Machine
resource "azurerm_virtual_machine" "vm-spoke" {
    name = "${var.app-name-vm}"
    location = azurerm_resource_group.rg-app-B.location
    resource_group_name = azurerm_resource_group.rg-app-B.name
    network_interface_ids = [azurerm_network_interface.nic-vmspoke.id]
    vm_size = "Standard_A1_v2"

    plan {
        publisher = var.vmspoke-publisher
        product = var.vmspoke-offer
        name = var.vmspoke-sku
    }
    storage_image_reference {
        publisher = var.vmspoke-publisher
        offer     = var.vmspoke-offer
        sku       = var.vmspoke-sku
        version   = "latest"
    }
    storage_os_disk {
        name              = "disk-${var.app-name-vm}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "${var.app-name-vm}"
		    admin_username = var.chkp-admin-usr
        admin_password = var.chkp-admin-pwd
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    depends_on = [azurerm_marketplace_agreement.vmspoke-agreement,azurerm_network_interface.nic-vmspoke]
}

resource "azurerm_resource_group" "rg-app-C" {
  name     = "rg-${var.app-name-direct}"
  location = var.location
}

resource "azurerm_public_ip" "publicip-app-C" {
  name                = "pub-${var.app-name-direct}"
  sku                 = "Standard"
  location            = azurerm_resource_group.rg-app-C.location
  resource_group_name = azurerm_resource_group.rg-app-C.name
  allocation_method   = "Static"
  domain_name_label   = "pub-${var.app-name-direct}-${var.mgmt-dns-suffix}"
}
resource "azurerm_network_interface" "nic-vmspoke-C" {
  name = "${var.app-name-direct}-eth0"
  location = azurerm_resource_group.rg-app-C.location
  resource_group_name = azurerm_resource_group.rg-app-C.name
  enable_ip_forwarding = "false"
    
	ip_configuration {
    name = "${var.app-name-direct}-eth0-config"
    subnet_id = azurerm_subnet.net-spoke-1-web.id
    private_ip_address_allocation = "Dynamic"
    primary = true
	  public_ip_address_id = azurerm_public_ip.publicip-app-C.id
	  gateway_load_balancer_frontend_ip_configuration_id = data.azurerm_lb.gateway-lb.frontend_ip_configuration.0.id
  }
  depends_on = [azurerm_subnet.net-spoke-1-web]
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-vmspoke-C" {
  network_interface_id      = azurerm_network_interface.nic-vmspoke-C.id
  network_security_group_id = azurerm_network_security_group.nsg-vmspoke.id
  depends_on = [azurerm_network_interface.nic-vmspoke-C,azurerm_network_security_group.nsg-vmspoke]
}

# VM-Spoke Virtual Machine
resource "azurerm_virtual_machine" "vm-spoke-C" {
  name = var.app-name-direct
  location = azurerm_resource_group.rg-app-C.location
  resource_group_name = azurerm_resource_group.rg-app-C.name
  network_interface_ids = [azurerm_network_interface.nic-vmspoke-C.id]
  vm_size = "Standard_A1_v2"

  plan {
    publisher = var.vmspoke-publisher
    product = var.vmspoke-offer
    name = var.vmspoke-sku
  }
  storage_image_reference {
    publisher = var.vmspoke-publisher
    offer     = var.vmspoke-offer
    sku       = var.vmspoke-sku
    version   = "latest"
  }
  storage_os_disk {
    name              = "disk-${var.app-name-direct}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.app-name-direct}"
	  admin_username = var.chkp-admin-usr
    admin_password = var.chkp-admin-pwd
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_marketplace_agreement.vmspoke-agreement,azurerm_network_interface.nic-vmspoke-C]
}

resource "azurerm_dns_a_record" "publicip-app-A-dns-record" {
  name                = var.app-name-con
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.publicip-app-A.id
  depends_on = [azurerm_public_ip.publicip-app-A]
}
output "webapp-A-public-fqdn" {
  value       = "http://${azurerm_dns_a_record.publicip-app-A-dns-record.name}.${azurerm_dns_zone.mydns-public-zone.name}:3000/"
}

resource "azurerm_dns_a_record" "publicip-app-B-dns-record" {
  name                = var.app-name-vm
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.publicip-app-B.id
  depends_on = [azurerm_public_ip.publicip-app-B]
}
output "webapp-B-public-fqdn" {
  value       = "http://${azurerm_dns_a_record.publicip-app-B-dns-record.name}.${azurerm_dns_zone.mydns-public-zone.name}/"
}

resource "azurerm_dns_a_record" "publicip-app-C-dns-record" {
  name                = var.app-name-direct
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.publicip-app-C.id
  depends_on = [azurerm_public_ip.publicip-app-C]
}
output "webapp-C-public-fqdn" {
  value       = "http://${azurerm_dns_a_record.publicip-app-C-dns-record.name}.${azurerm_dns_zone.mydns-public-zone.name}/"
}