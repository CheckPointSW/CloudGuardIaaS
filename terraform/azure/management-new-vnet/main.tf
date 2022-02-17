//********************** Providers **************************//
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id

  features {}
}

//********************** Basic Configuration **************************//
module "common" {
  source = "../modules/common"
  resource_group_name = var.resource_group_name
  location = var.location
  admin_password = var.admin_password
  installation_type = var.installation_type
  template_name = var.template_name
  template_version = var.template_version
  number_of_vm_instances = 1
  allow_upload_download = var.allow_upload_download
  vm_size = var.vm_size
  disk_size = var.disk_size
  is_blink = false
  os_version = var.os_version
  vm_os_sku = var.vm_os_sku
  vm_os_offer = var.vm_os_offer
  authentication_type = var.authentication_type
}

//********************** Networking **************************//
module "vnet" {
  source = "../modules/vnet"

  vnet_name = var.vnet_name
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  address_space = var.address_space
  subnet_prefixes = [var.subnet_prefix]
  subnet_names = ["${var.mgmt_name}-subnet"]
  nsg_id = module.network-security-group.network_security_group_id
}

module "network-security-group" {
  source = "../modules/network-security-group"
  resource_group_name = module.common.resource_group_name
  security_group_name = "${module.common.resource_group_name}-nsg"
  location = module.common.resource_group_location
  security_rules = [
    {
      name = "SSH"
      priority = "100"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "22"
      description = "Allow inbound SSH connection"
      source_address_prefix = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name = "GAiA-portal"
      priority = "110"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "443"
      description = "Allow inbound HTTPS access to the GAiA portal"
      source_address_prefix = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name = "SmartConsole-1"
      priority = "120"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "18190"
      description = "Allow inbound access using the SmartConsole GUI client"
      source_address_prefix = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name = "SmartConsole-2"
      priority = "130"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "19009"
      description = "Allow inbound access using the SmartConsole GUI client"
      source_address_prefix = var.management_GUI_client_network
      destination_address_prefix = "*"
    },
    {
      name = "Logs"
      priority = "140"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "257"
      description = "Allow inbound logging connections from managed gateways"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    },
    {
      name = "ICA-pull"
      priority = "150"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "18210"
      description = "Allow security gateways to pull a SIC certificate"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    },
    {
      name = "CRL-fetch"
      priority = "160"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "18264"
      description = "Allow security gateways to fetch CRLs"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    },
    {
      name = "Policy-fetch"
      priority = "170"
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_ranges = "*"
      destination_port_ranges = "18191"
      description = "Allow security gateways to fetch policy"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  ]
}

resource "azurerm_public_ip" "public-ip" {
  name = var.mgmt_name
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method = var.vnet_allocation_method
  idle_timeout_in_minutes = 30
  domain_name_label = join("", [
    var.mgmt_name,
    "-",
    random_id.randomId.hex])
}

resource "azurerm_network_interface_security_group_association" "security_group_association" {
  depends_on = [azurerm_network_interface.nic, module.network-security-group.network_security_group_id]
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = module.network-security-group.network_security_group_id
}

resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_public_ip.public-ip]
  name = "${var.mgmt_name}-eth0"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  enable_ip_forwarding = false

  ip_configuration {
    name = "ipconfig1"
    subnet_id = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(var.subnet_prefix, 4)
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

//********************** Storage accounts **************************//
// Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = module.common.resource_group_name
  }
  byte_length = 8
}
resource "azurerm_storage_account" "vm-boot-diagnostics-storage" {
  name = "bootdiag${random_id.randomId.hex}"
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  account_tier = module.common.storage_account_tier
  account_replication_type = module.common.account_replication_type
  account_kind = "Storage"
}

//********************** Virtual Machines **************************//
locals {
  SSH_authentication_type_condition = var.authentication_type == "SSH Public Key" ? true : false
  custom_image_condition = var.source_image_vhd_uri == "noCustomUri" ? false : true
}

resource "azurerm_image" "custom-image" {
  count = local.custom_image_condition ? 1 : 0
  name = "custom-image"
  location = var.location
  resource_group_name = module.common.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.source_image_vhd_uri
  }
}

resource "azurerm_virtual_machine" "mgmt-vm-instance" {
  depends_on = [
    azurerm_network_interface.nic]
  location = module.common.resource_group_location
  name = var.mgmt_name
  network_interface_ids = [
    azurerm_network_interface.nic.id]
  resource_group_name = module.common.resource_group_name
  vm_size = module.common.vm_size
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id = azurerm_network_interface.nic.id

  identity {
    type = module.common.vm_instance_identity
  }

  dynamic "plan" {
    for_each = local.custom_image_condition ? [
    ] : [1]
    content {
      name = module.common.vm_os_sku
      publisher = module.common.publisher
      product = module.common.vm_os_offer
    }
  }

  boot_diagnostics {
    enabled = module.common.boot_diagnostics
    storage_uri = module.common.boot_diagnostics ? join(",", azurerm_storage_account.vm-boot-diagnostics-storage.*.primary_blob_endpoint) : ""
  }

  os_profile {
    computer_name = var.mgmt_name
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type = module.common.installation_type
      allow_upload_download = module.common.allow_upload_download
      os_version = module.common.os_version
      template_name = module.common.template_name
      template_version = module.common.template_version
      template_type = "terraform"
      is_blink = module.common.is_blink
      bootstrap_script64 = base64encode(var.bootstrap_script)
      location = module.common.resource_group_location
      management_GUI_client_network = var.management_GUI_client_network
      enable_api = var.mgmt_enable_api
      admin_shell = var.admin_shell
    })
  }

  os_profile_linux_config {
    disable_password_authentication = local.SSH_authentication_type_condition

    dynamic "ssh_keys" {
      for_each = local.SSH_authentication_type_condition ? [
        1] : []
      content {
        path = "/home/notused/.ssh/authorized_keys"
        key_data = file("${path.module}/azure_public_key")
      }
    }
  }

  storage_image_reference {
    id = local.custom_image_condition ? azurerm_image.custom-image[0].id : null
    publisher = local.custom_image_condition ? null : module.common.publisher
    offer = module.common.vm_os_offer
    sku = module.common.vm_os_sku
    version = module.common.vm_os_version
  }

  storage_os_disk {
    name = var.mgmt_name
    create_option = module.common.storage_os_disk_create_option
    caching = module.common.storage_os_disk_caching
    managed_disk_type = module.common.storage_account_type
    disk_size_gb = module.common.disk_size
  }
}
