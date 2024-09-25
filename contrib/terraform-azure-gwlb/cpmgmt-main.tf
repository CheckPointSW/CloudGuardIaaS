# Accept the agreement for the mgmt-byol for R80.40
resource "azurerm_marketplace_agreement" "cpmgmt-agreement" {
  count     = var.mgmt-sku-enabled ? 0 : 1
  publisher = "checkpoint"
  offer     = "check-point-cg-${var.mgmt-version}"
  plan      = var.mgmt-sku
}
# Create management resource group
resource "azurerm_resource_group" "rg-ckpmgmt" {
  name      = "rg-${var.mgmt-name}"
  location  = var.location
}
# Create NSG for the management
resource "azurerm_network_security_group" "nsg-ckpmgmt" {
  name      = "nsg-${var.mgmt-name}"
  location  = azurerm_resource_group.rg-ckpmgmt.location
  resource_group_name = azurerm_resource_group.rg-ckpmgmt.name
  depends_on = [azurerm_resource_group.rg-ckpmgmt]
}

# Create the NSG rules for the management
resource "azurerm_network_security_rule" "nsg-ckpmgmt-rl-ssh" {
  priority  = 100
  name      = "ssh-access"
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my-pub-ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-ckpmgmt.name
  network_security_group_name = azurerm_network_security_group.nsg-ckpmgmt.name
  depends_on = [azurerm_network_security_group.nsg-ckpmgmt]
}
resource "azurerm_network_security_rule" "nsg-ckpmgmt-rl-https" {
  priority  = 110
  name      = "https-access"
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.my-pub-ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-ckpmgmt.name
  network_security_group_name = azurerm_network_security_group.nsg-ckpmgmt.name
  depends_on = [azurerm_network_security_group.nsg-ckpmgmt]
}
resource "azurerm_network_security_rule" "nsg-ckpmgmt-rl-smartconsole" {
  priority  = 120
  name      = "smartconsole-access"
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range           = "*"
  destination_port_ranges     = ["18190","19009"]
  source_address_prefix       = var.my-pub-ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-ckpmgmt.name
  network_security_group_name = azurerm_network_security_group.nsg-ckpmgmt.name
  depends_on = [azurerm_network_security_group.nsg-ckpmgmt]
}
resource "azurerm_network_security_rule" "nsg-ckpmgmt-rl-exposedsrvc" {
  priority  = 130
  name      = "log-ICA-CRL-Policy-access"
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range           = "*"
  destination_port_ranges     = ["257","18210","18264","18191"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-ckpmgmt.name
  network_security_group_name = azurerm_network_security_group.nsg-ckpmgmt.name
  depends_on = [azurerm_network_security_group.nsg-ckpmgmt]
}

# Create Public IP
resource "azurerm_public_ip" "pub-ckpmgmt" {
    name      = "pub-${var.mgmt-name}"
    location  = azurerm_resource_group.rg-ckpmgmt.location
    resource_group_name = azurerm_resource_group.rg-ckpmgmt.name
    allocation_method   = "Dynamic"
    domain_name_label   = "pub-${var.mgmt-name}-${var.mgmt-dns-suffix}"
    depends_on = [azurerm_resource_group.rg-ckpmgmt]
}
# Create NIC
resource "azurerm_network_interface" "nic-ckpmgmt" {
    name                = "${var.mgmt-name}-eth0"
    location            = azurerm_resource_group.rg-ckpmgmt.location
    resource_group_name = azurerm_resource_group.rg-ckpmgmt.name
    enable_ip_forwarding = "false"
  
	ip_configuration {
      name      = "${var.mgmt-name}-eth0-config"
      subnet_id = azurerm_subnet.net-secmgmt.id
      primary   = true  
		  private_ip_address = "172.16.8.4"
      private_ip_address_allocation = "Static"
		  public_ip_address_id = azurerm_public_ip.pub-ckpmgmt.id
    }
    depends_on = [azurerm_public_ip.pub-ckpmgmt,azurerm_subnet.net-secmgmt,azurerm_network_security_group.nsg-ckpmgmt]
}
resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-ckpmgmt" {
  network_interface_id      = azurerm_network_interface.nic-ckpmgmt.id
  network_security_group_id = azurerm_network_security_group.nsg-ckpmgmt.id
  depends_on = [azurerm_network_interface.nic-ckpmgmt,azurerm_network_security_group.nsg-ckpmgmt]
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg-ckpmgmt.name
    }
    byte_length = 8
    depends_on = [azurerm_resource_group.rg-ckpmgmt]
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "ckp-storageaccount" {
    blob_properties {
      delete_retention_policy {
        days = 7
      }
    }
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rg-ckpmgmt.name
    location                    = azurerm_resource_group.rg-ckpmgmt.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    depends_on = [random_id.randomId,azurerm_resource_group.rg-ckpmgmt]
}

# Create virtual machine
resource "azurerm_virtual_machine" "ckpmgmt" {
    name                  = var.mgmt-name
    location              = azurerm_resource_group.rg-ckpmgmt.location
    resource_group_name   = azurerm_resource_group.rg-ckpmgmt.name
    network_interface_ids = [azurerm_network_interface.nic-ckpmgmt.id]
    primary_network_interface_id = azurerm_network_interface.nic-ckpmgmt.id
    vm_size               = var.mgmt-size
    
    # parameters = { "installationType" = "management" }

    storage_os_disk {
        name              = "disk-${var.mgmt-name}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_image_reference {
        publisher = "checkpoint"
        offer     = "check-point-cg-${var.mgmt-version}"
        sku       = var.mgmt-sku
        version   = "latest"
    }
    plan {
        name      = var.mgmt-sku
        publisher = "checkpoint"
        product   = "check-point-cg-${var.mgmt-version}"
    }
    os_profile {
        computer_name   = var.mgmt-name
		    admin_username  = var.chkp-admin-usr
        admin_password  = var.chkp-admin-pwd
        custom_data     = file("customdata.sh")
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.ckp-storageaccount.primary_blob_endpoint
    }
    depends_on = [azurerm_marketplace_agreement.cpmgmt-agreement,azurerm_resource_group.rg-ckpmgmt,azurerm_network_interface.nic-ckpmgmt,azurerm_storage_account.ckp-storageaccount]
}

resource "azurerm_dns_a_record" "mgmt-dns-record" {
  name                = "ckpmgmt"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.pub-ckpmgmt.id
  depends_on = [azurerm_public_ip.pub-ckpmgmt]
}
output "ckpmgmt-public-fqdn" {
  value       = "https://${azurerm_dns_a_record.mgmt-dns-record.name}.${azurerm_dns_zone.mydns-public-zone.name}/"
}