//********************** Providers **************************//
provider "azurerm" {
  version = "=1.44.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "random" {
  version = "= 2.2.1"
}

//********************** Basic Configuration **************************//
module "common" {
  source = "../modules/common"
  resource_group_name = var.resource_group_name
  location = var.location
  admin_password = var.admin_password
  sic_key = var.sic_key
  installation_type = var.installation_type
  template_name = var.template_name
  template_version = var.template_version
  number_of_vm_instances = var.number_of_vm_instances
  allow_upload_download = var.allow_upload_download
  vm_size = var.vm_size
  disk_size = var.disk_size
  is_blink = var.is_blink
  os_version = var.os_version
  vm_os_sku = var.vm_os_sku
  vm_os_offer = var.vm_os_offer
  disable_password_authentication = var.disable_password_authentication
}

//********************** Networking **************************//
module "vnet" {
  source = "../modules/vnet"
  vnet_name = var.vnet_name
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  nsg_id = module.network-security-group.network_security_group_id
  address_space = var.address_space
  subnet_prefixes = var.subnet_prefixes
}

module "network-security-group" {
    source = "../modules/network-security-group"
    resource_group_name = module.common.resource_group_name
    security_group_name = "${module.common.resource_group_name}_nsg"
    location = module.common.resource_group_location
    security_rules = [
      {
        name = "AllowAllInBound"
        priority = "100"
        direction = "Inbound"
        access = "Allow"
        protocol = "*"
        source_port_ranges = "*"
        destination_port_ranges = "*"
        description = "Allow all inbound connections"
        source_address_prefix = "*"
        destination_address_prefix = "*"
      }
    ]
}

resource "azurerm_public_ip" "public-ip" {
    count = 2
    name = "${var.cluster_name}${count.index+1}_IP"
    location = module.common.resource_group_location
    resource_group_name = module.common.resource_group_name
    allocation_method   = module.vnet.allocation_method
    sku = var.sku
}

resource "azurerm_public_ip" "cluster-vip" {
    name = var.cluster_name
    location = module.common.resource_group_location
    resource_group_name = module.common.resource_group_name
    allocation_method   = module.vnet.allocation_method
    sku = var.sku

}

resource "azurerm_network_interface" "nic_vip" {
  depends_on = [azurerm_public_ip.cluster-vip,azurerm_public_ip.public-ip]
  name = "${var.cluster_name}1-eth0"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name = "ipconfig1"
    primary = true
    subnet_id = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address = cidrhost(module.vnet.subnet_prefixes[0], 5)
    public_ip_address_id = azurerm_public_ip.public-ip.0.id
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.frontend-lb-pool.id]
  }
    ip_configuration {
    name                          = "cluster-vip"
    subnet_id                     = module.vnet.vnet_subnets[0]
    primary                       = false
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 7)
    public_ip_address_id          = azurerm_public_ip.cluster-vip.id
  }
}

resource "azurerm_network_interface" "nic" {
  depends_on = [azurerm_public_ip.public-ip, azurerm_lb.frontend-lb]
  name                 = "${var.cluster_name}2-eth0"
  location             = module.common.resource_group_location
  resource_group_name  = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[0], 6)
    public_ip_address_id          = azurerm_public_ip.public-ip.1.id
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.frontend-lb-pool.id]
  }

}

resource "azurerm_network_interface" "nic1" {
  depends_on = [azurerm_lb.backend-lb]
  count = 2
  name                 = "${var.cluster_name}${count.index+1}-eth1"
  location             = module.common.resource_group_location
  resource_group_name  = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = module.vnet.vnet_subnets[1]
    private_ip_address_allocation = module.vnet.allocation_method
    private_ip_address            = cidrhost(module.vnet.subnet_prefixes[1], count.index+5)
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.backend-lb-pool.id]
  }
}

//********************** Load Balancers **************************//
resource "azurerm_public_ip" "public-ip-lb" {
    name                         = "frontend_lb_ip"
    location            = module.common.resource_group_location
    resource_group_name = module.common.resource_group_name
    allocation_method   = module.vnet.allocation_method
    sku = var.sku
}

resource "azurerm_lb" "frontend-lb" {
 depends_on = [azurerm_public_ip.public-ip-lb]
 name = "frontend-lb"
 location = module.common.resource_group_location
 resource_group_name = module.common.resource_group_name
 sku = var.sku

 frontend_ip_configuration {
   name = "LoadBalancerFrontend"
   public_ip_address_id = azurerm_public_ip.public-ip-lb.id
 }
}

resource "azurerm_lb_backend_address_pool" "frontend-lb-pool" {
 resource_group_name = module.common.resource_group_name
 loadbalancer_id = azurerm_lb.frontend-lb.id
 name = "frontend-lb-pool"
}

resource "azurerm_lb" "backend-lb" {
 name = "backend-lb"
 location = module.common.resource_group_location
 resource_group_name = module.common.resource_group_name
 sku = var.sku
 frontend_ip_configuration {
   name = "backend-lb"
   subnet_id =  module.vnet.vnet_subnets[1]
   private_ip_address_allocation = module.vnet.allocation_method
   private_ip_address = cidrhost(module.vnet.subnet_prefixes[1], 4)
 }
}

resource "azurerm_lb_backend_address_pool" "backend-lb-pool" {
  name = "backend-lb-pool"
  loadbalancer_id = azurerm_lb.backend-lb.id
  resource_group_name = module.common.resource_group_name
}

resource "azurerm_lb_probe" "azure_lb_healprob" {
  count = 2
  resource_group_name = module.common.resource_group_name
  loadbalancer_id = count.index == 0 ? azurerm_lb.frontend-lb.id : azurerm_lb.backend-lb.id
  name = var.lb_probe_name
  protocol = var.lb_probe_protocol
  port = var.lb_probe_port
  interval_in_seconds = var.lb_probe_interval
  number_of_probes = var.lb_probe_unhealthy_threshold
}

   resource "azurerm_lb_rule" "backend_lb_rule" {
     count = 2
     resource_group_name = module.common.resource_group_name
     loadbalancer_id = azurerm_lb.backend-lb.id
     name  ="backend-lb-rule"
     protocol = "All"
     frontend_ip_configuration_name = "backend-lb"
     frontend_port =0
     backend_port =0
     backend_address_pool_id = azurerm_lb_backend_address_pool.backend-lb-pool.id
     probe_id =  azurerm_lb_probe.azure_lb_healprob[count.index].id
 }
     
  
//********************** Availability Set **************************//
resource "azurerm_availability_set" "availability-set" {
  name = "${var.cluster_name}-AvailabilitySet"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  platform_fault_domain_count = 2
  platform_update_domain_count = 5
  managed = true
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
}

//********************** Virtual Machines **************************//
resource "azurerm_virtual_machine" "vm-instance" {
  depends_on = [azurerm_network_interface.nic, azurerm_network_interface.nic1,azurerm_network_interface.nic_vip, azurerm_availability_set.availability-set]
  count = module.common.number_of_vm_instances
  name = "${var.cluster_name}${count.index+1}"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  availability_set_id = azurerm_availability_set.availability-set.id
  vm_size = module.common.vm_size
  network_interface_ids = count.index == 0 ? [azurerm_network_interface.nic_vip.id, azurerm_network_interface.nic1.0.id] : [azurerm_network_interface.nic.id, azurerm_network_interface.nic1.1.id]
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id = count.index == 0 ? azurerm_network_interface.nic_vip.id : azurerm_network_interface.nic.id
  identity {
      type = module.common.vm_instance_identity
  }
  storage_image_reference {
    publisher = module.common.publisher
    offer = module.common.vm_os_offer
    sku = module.common.vm_os_sku
    version = module.common.vm_os_version
  }

  storage_os_disk {
    name = "${var.cluster_name}-${count.index+1}"
    create_option = module.common.storage_os_disk_create_option
    caching = module.common.storage_os_disk_caching
    managed_disk_type = module.common.storage_account_type
    disk_size_gb = module.common.disk_size
  }

  plan {
    name = module.common.vm_os_sku
    publisher = module.common.publisher
    product = module.common.vm_os_offer
  }

  os_profile {
    computer_name  = "${var.cluster_name}${count.index+1}"
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh",{
      installation_type=module.common.installation_type
      allow_upload_download= module.common.allow_upload_download
      os_version=module.common.os_version
      template_name=module.common.template_name
      template_version=module.common.template_version
      is_blink=module.common.is_blink
      bootstrap_script64=base64encode(var.bootstrap_script)
      location=module.common.resource_group_location
      sic_key=module.common.sic_key
      tenant_id=var.tenant_id
      virtual_network=module.vnet.vnet_name
      cluster_name=var.cluster_name
      external_private_addresses=azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address
    })
  }

  os_profile_linux_config {
    disable_password_authentication = module.common.disable_password_authentication

    ssh_keys {
      path = "/home/notused/.ssh/authorized_keys"
      key_data = file("${path.module}/azure_public_key")
    }
  }

  boot_diagnostics {
    enabled = module.common.boot_diagnostics
    storage_uri = module.common.boot_diagnostics ? join(",", azurerm_storage_account.vm-boot-diagnostics-storage.*.primary_blob_endpoint) : ""
  }
}

//********************** Role Assigments **************************//
data "azurerm_role_definition" "role_definition" {
  name = module.common.role_definition
}
data "azurerm_client_config" "client_config" {
}
resource "azurerm_role_assignment" "cluster_assigment" {
  depends_on = [azurerm_virtual_machine.vm-instance]
  count = 2
  scope = module.common.resource_group_id
  role_definition_id = data.azurerm_role_definition.role_definition.id
  principal_id = lookup(azurerm_virtual_machine.vm-instance[count.index].identity[0], "principal_id")
}
