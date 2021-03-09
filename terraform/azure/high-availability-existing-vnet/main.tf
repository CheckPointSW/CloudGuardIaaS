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
  number_of_vm_instances = var.number_of_vm_instances
  allow_upload_download = var.allow_upload_download
  vm_size = var.vm_size
  disk_size = var.disk_size
  is_blink = var.is_blink
  os_version = var.os_version
  vm_os_sku = var.vm_os_sku
  vm_os_offer = var.vm_os_offer
  authentication_type = var.authentication_type
}

//********************** Networking **************************//
data "azurerm_subnet" "frontend" {
  name = var.frontend_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

data "azurerm_subnet" "backend" {
  name = var.backend_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

resource "azurerm_public_ip" "public-ip" {
  count = 2
  name = "${var.cluster_name}${count.index+1}_IP"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method = var.vnet_allocation_method
  sku = var.sku
}

resource "azurerm_public_ip" "cluster-vip" {
  name = var.cluster_name
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method = var.vnet_allocation_method
  sku = var.sku
}

resource "azurerm_network_interface" "nic_vip" {
  depends_on = [
    azurerm_public_ip.cluster-vip,
    azurerm_public_ip.public-ip]
  name = "${var.cluster_name}1-eth0"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name = "ipconfig1"
    primary = true
    subnet_id = data.azurerm_subnet.frontend.id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(data.azurerm_subnet.frontend.address_prefix, var.frontend_IP_addresses[0])
    public_ip_address_id = azurerm_public_ip.public-ip.0.id
  }
  ip_configuration {
    name = "cluster-vip"
    subnet_id = data.azurerm_subnet.frontend.id
    primary = false
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(data.azurerm_subnet.frontend.address_prefix, var.frontend_IP_addresses[2])
    public_ip_address_id = azurerm_public_ip.cluster-vip.id
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to ip_configuration when Re-applying, e.g. because a cluster failover and associating the cluster- vip with the other member.
      # updates these based on some ruleset managed elsewhere.
      ip_configuration
    ]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_vip_lb_association" {
  depends_on = [azurerm_network_interface.nic_vip, azurerm_lb_backend_address_pool.frontend-lb-pool]
  network_interface_id    = azurerm_network_interface.nic_vip.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend-lb-pool.id
}

resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_public_ip.public-ip,
    azurerm_lb.frontend-lb]
  name = "${var.cluster_name}2-eth0"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name = "ipconfig1"
    primary = true
    subnet_id = data.azurerm_subnet.frontend.id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(data.azurerm_subnet.frontend.address_prefix, var.frontend_IP_addresses[1])
    public_ip_address_id = azurerm_public_ip.public-ip.1.id
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to ip_configuration when Re-applying, e.g. because a cluster failover and associating the cluster- vip with the other member.
      # updates these based on some ruleset managed elsewhere.
      ip_configuration
    ]
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  depends_on = [azurerm_network_interface.nic, azurerm_lb_backend_address_pool.frontend-lb-pool]
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend-lb-pool.id
}

resource "azurerm_network_interface" "nic1" {
  depends_on = [
    azurerm_lb.backend-lb]
  count = 2
  name = "${var.cluster_name}${count.index+1}-eth1"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  enable_ip_forwarding = true
  enable_accelerated_networking = true

  ip_configuration {
    name = "ipconfig2"
    subnet_id = data.azurerm_subnet.backend.id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(data.azurerm_subnet.backend.address_prefix, var.backend_IP_addresses[count.index+1])
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic1_lb_association" {
  depends_on = [azurerm_network_interface.nic1, azurerm_lb_backend_address_pool.backend-lb-pool]
  count = 2
  network_interface_id    = azurerm_network_interface.nic1[count.index].id
  ip_configuration_name   = "ipconfig2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-lb-pool.id
}

//********************** Load Balancers **************************//
resource "azurerm_public_ip" "public-ip-lb" {
  name = "frontend_lb_ip"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method = var.vnet_allocation_method
  sku = var.sku
}

resource "azurerm_lb" "frontend-lb" {
  depends_on = [
    azurerm_public_ip.public-ip-lb]
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
    subnet_id = data.azurerm_subnet.backend.id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address = cidrhost(data.azurerm_subnet.backend.address_prefix, var.backend_IP_addresses[0])
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

//********************** Availability Set **************************//
locals {
  availability_set_condition = var.availability_type == "Availability Set" ? true : false
  SSH_authentication_type_condition = var.authentication_type == "SSH Public Key" ? true : false
}
resource "azurerm_availability_set" "availability-set" {
  count = local.availability_set_condition ? 1 : 0
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
locals {
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
resource "azurerm_virtual_machine" "vm-instance-availability-set" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic_vip]
  count = local.availability_set_condition ? module.common.number_of_vm_instances : 0
  name = "${var.cluster_name}${count.index+1}"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  availability_set_id = local.availability_set_condition ? azurerm_availability_set.availability-set[0].id : ""
  vm_size = module.common.vm_size
  network_interface_ids = count.index == 0 ? [
    azurerm_network_interface.nic_vip.id,
    azurerm_network_interface.nic1.0.id] : [
    azurerm_network_interface.nic.id,
    azurerm_network_interface.nic1.1.id]
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id = count.index == 0 ? azurerm_network_interface.nic_vip.id : azurerm_network_interface.nic.id
  identity {
    type = module.common.vm_instance_identity
  }
  storage_image_reference {
    id = local.custom_image_condition ? azurerm_image.custom-image[0].id : null
    publisher = local.custom_image_condition ? null : module.common.publisher
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

  dynamic "plan" {
    for_each = local.custom_image_condition ? [
    ] : [1]
    content {
      name = module.common.vm_os_sku
      publisher = module.common.publisher
      product = module.common.vm_os_offer
    }
  }

  os_profile {
    computer_name = "${var.cluster_name}${count.index+1}"
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type = module.common.installation_type
      allow_upload_download = module.common.allow_upload_download
      os_version = module.common.os_version
      template_name = module.common.template_name
      template_version = module.common.template_version
      is_blink = module.common.is_blink
      bootstrap_script64 = base64encode(var.bootstrap_script)
      location = module.common.resource_group_location
      sic_key = var.sic_key
      tenant_id = var.tenant_id
      virtual_network = var.vnet_name
      cluster_name = var.cluster_name
      external_private_addresses = azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address
      enable_custom_metrics=var.enable_custom_metrics ? "yes" : "no"
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

  boot_diagnostics {
    enabled = module.common.boot_diagnostics
    storage_uri = module.common.boot_diagnostics ? join(",", azurerm_storage_account.vm-boot-diagnostics-storage.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_virtual_machine" "vm-instance-availability-zone" {
  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic_vip]
  count = local.availability_set_condition ? 0 : module.common.number_of_vm_instances
  name = "${var.cluster_name}${count.index+1}"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  zones = [
    count.index+1]
  vm_size = module.common.vm_size
  network_interface_ids = count.index == 0 ? [
    azurerm_network_interface.nic_vip.id,
    azurerm_network_interface.nic1.0.id] : [
    azurerm_network_interface.nic.id,
    azurerm_network_interface.nic1.1.id]
  delete_os_disk_on_termination = module.common.delete_os_disk_on_termination
  primary_network_interface_id = count.index == 0 ? azurerm_network_interface.nic_vip.id : azurerm_network_interface.nic.id
  identity {
    type = module.common.vm_instance_identity
  }
  storage_image_reference {
    id = local.custom_image_condition ? azurerm_image.custom-image[0].id : null
    publisher = local.custom_image_condition ? null : module.common.publisher
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

  dynamic "plan" {
    for_each = local.custom_image_condition ? [
    ] : [1]
    content {
      name = module.common.vm_os_sku
      publisher = module.common.publisher
      product = module.common.vm_os_offer
    }
  }

  os_profile {
    computer_name = "${var.cluster_name}${count.index+1}"
    admin_username = module.common.admin_username
    admin_password = module.common.admin_password
    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type = module.common.installation_type
      allow_upload_download = module.common.allow_upload_download
      os_version = module.common.os_version
      template_name = module.common.template_name
      template_version = module.common.template_version
      is_blink = module.common.is_blink
      bootstrap_script64 = base64encode(var.bootstrap_script)
      location = module.common.resource_group_location
      sic_key = var.sic_key
      tenant_id = var.tenant_id
      virtual_network = var.vnet_name
      cluster_name = var.cluster_name
      external_private_addresses = azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address
      enable_custom_metrics=var.enable_custom_metrics ? "yes" : "no"
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
  count = 2
  lifecycle {
    ignore_changes = [
      role_definition_id, principal_id
    ]
  }
  scope = module.common.resource_group_id
  role_definition_id = data.azurerm_role_definition.role_definition.id
  principal_id = local.availability_set_condition ? lookup(azurerm_virtual_machine.vm-instance-availability-set[count.index].identity[0], "principal_id") : lookup(azurerm_virtual_machine.vm-instance-availability-zone[count.index].identity[0], "principal_id")
}