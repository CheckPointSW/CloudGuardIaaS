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
  admin_password = var.authentication_type == "SSH Public Key" ? random_id.random_id.hex : var.admin_password
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
  serial_console_password_hash = var.serial_console_password_hash
  maintenance_mode_password_hash = var.maintenance_mode_password_hash
  storage_account_additional_ips = var.storage_account_additional_ips
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

module "network-security-group" {
    source = "../modules/network-security-group"
    count = var.nsg_id == "" ? 1 : 0
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

//********************** Load Balancers **************************//
resource "random_id" "random_id" {
  byte_length = 13
  keepers = {
    rg_id = module.common.resource_group_id
  }
}

resource "azurerm_public_ip" "public-ip-lb" {
  count = var.deployment_mode != "Internal" ? 1 : 0
  name = "${var.vmss_name}-app-1"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  allocation_method = var.vnet_allocation_method
  sku = var.sku
  domain_name_label = "${lower(var.vmss_name)}-${random_id.random_id.hex}"
}

resource "azurerm_lb" "frontend-lb" {
  count = var.deployment_mode != "Internal" ? 1 : 0
  depends_on = [azurerm_public_ip.public-ip-lb]
  name = "frontend-lb"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku = var.sku

  frontend_ip_configuration {
    name = "${var.vmss_name}-app-1"
    public_ip_address_id = azurerm_public_ip.public-ip-lb[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "frontend-lb-pool" {
  count = var.deployment_mode != "Internal" ? 1 : 0
  loadbalancer_id = azurerm_lb.frontend-lb[0].id
  name = "${var.vmss_name}-app-1"
}

resource "azurerm_lb" "backend-lb" {
  count = var.deployment_mode != "External" ? 1 : 0
  name = "backend-lb"
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku = var.sku
  frontend_ip_configuration {
    name = "backend-lb"
    subnet_id = data.azurerm_subnet.backend.id
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(data.azurerm_subnet.backend.address_prefixes[0],var.backend_lb_IP_address)
  }
}

resource "azurerm_lb_backend_address_pool" "backend-lb-pool" {
  count = var.deployment_mode != "External" ? 1 : 0
  name = "backend-lb-pool"
  loadbalancer_id = azurerm_lb.backend-lb[0].id
}

resource "azurerm_lb_probe" "azure_lb_healprob" {
  count = var.deployment_mode == "Standard" ? 2 : 1
  depends_on = [azurerm_lb.frontend-lb, azurerm_lb.backend-lb]
  loadbalancer_id = var.deployment_mode == "Standard" ? (count.index == 0 ? azurerm_lb.frontend-lb[0].id : azurerm_lb.backend-lb[0].id) : (var.deployment_mode == "External" ? azurerm_lb.frontend-lb[0].id : azurerm_lb.backend-lb[0].id)
  name = var.deployment_mode == "Standard" ? (count.index == 0 ? "${var.vmss_name}-app-1" : "backend-lb") : (var.deployment_mode == "External" ? "${var.vmss_name}-app-1" : "backend-lb")
  protocol = var.lb_probe_protocol
  port = var.lb_probe_port
  interval_in_seconds = var.lb_probe_interval
  number_of_probes = var.lb_probe_unhealthy_threshold
}

// Standard deployment
resource "azurerm_lb_rule" "lbnatrule-standard" {
  count = var.deployment_mode == "Standard" ? 2 : 0
  depends_on = [azurerm_lb.frontend-lb[0],azurerm_lb_probe.azure_lb_healprob,azurerm_lb.backend-lb[0]]
  loadbalancer_id = count.index == 0 ? azurerm_lb.frontend-lb[0].id : azurerm_lb.backend-lb[0].id
  name = count.index == 0 ? "${var.vmss_name}-app-1" : "backend-lb"
  protocol = count.index == 0 ? "Tcp" : "All"
  frontend_port = count.index == 0 ? var.frontend_port : "0"
  backend_port = count.index == 0 ? var.backend_port : "0"
  backend_address_pool_ids = count.index == 0 ? [azurerm_lb_backend_address_pool.frontend-lb-pool[0].id] : [azurerm_lb_backend_address_pool.backend-lb-pool[0].id]
  frontend_ip_configuration_name = count.index == 0 ? azurerm_lb.frontend-lb[0].frontend_ip_configuration[0].name : azurerm_lb.backend-lb[0].frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.azure_lb_healprob[count.index].id
  load_distribution = count.index == 0 ? var.frontend_load_distribution : var.backend_load_distribution
  enable_floating_ip = var.enable_floating_ip
}

// External deployment
resource "azurerm_lb_rule" "lbnatrule-external" {
  count = var.deployment_mode == "External" ? 1 : 0
  depends_on = [azurerm_lb.frontend-lb[0],azurerm_lb_probe.azure_lb_healprob]
  loadbalancer_id = azurerm_lb.frontend-lb[0].id
  name = "${var.vmss_name}-app-1"
  protocol = "Tcp"
  frontend_port = var.frontend_port
  backend_port = var.backend_port
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.frontend-lb-pool[0].id]
  frontend_ip_configuration_name = azurerm_lb.frontend-lb[0].frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.azure_lb_healprob[0].id
  load_distribution = var.frontend_load_distribution
  enable_floating_ip = var.enable_floating_ip
}

// Internal deployment
resource "azurerm_lb_rule" "lbnatrule-internal" {
  count = var.deployment_mode == "Internal" ? 1 : 0
  depends_on = [azurerm_lb_probe.azure_lb_healprob,azurerm_lb.backend-lb[0]]
  loadbalancer_id = azurerm_lb.backend-lb[0].id
  name = "backend-lb"
  protocol = "All"
  frontend_port = "0"
  backend_port = "0"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend-lb-pool[0].id]
  frontend_ip_configuration_name = azurerm_lb.backend-lb[0].frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.azure_lb_healprob[0].id
  load_distribution = var.backend_load_distribution
  enable_floating_ip = var.enable_floating_ip
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
  name = "diag${random_id.randomId.hex}"
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  account_tier = module.common.storage_account_tier
  account_replication_type = module.common.account_replication_type
  network_rules {
    default_action = var.add_storage_account_ip_rules ? "Deny" : "Allow"
    ip_rules = module.common.storage_account_ip_rules
  }
  blob_properties {
    delete_retention_policy {
      days = "15"
    }
   }
}


//********************** Virtual Machines **************************//
locals {
  SSH_authentication_type_condition = var.authentication_type == "SSH Public Key" ? true : false
  availability_zones_num_condition = var.availability_zones_num == "0" ? null : var.availability_zones_num == "1" ? ["1"] : var.availability_zones_num == "2" ? ["1", "2"] : ["1", "2", "3"]
  custom_image_condition = var.source_image_vhd_uri == "noCustomUri" ? false : true
  management_interface_name = split("-", var.management_interface)[0]
  management_ip_address_type = split("-", var.management_interface)[1]
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

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name = var.vmss_name
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  sku = module.common.vm_size
  zones = local.availability_zones_num_condition
  instances = var.number_of_vm_instances
  overprovision = false

  dynamic "identity" {
    for_each = var.enable_custom_metrics ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "source_image_reference" {
    for_each = local.custom_image_condition ? [] : [1]
    content {
      publisher = module.common.publisher
      offer     = module.common.vm_os_offer
      sku       = module.common.vm_os_sku
      version   = module.common.vm_os_version
    }
  }
  source_image_id = local.custom_image_condition? azurerm_image.custom-image[0].id : null

  os_disk {
    disk_size_gb = module.common.disk_size
    caching = module.common.storage_os_disk_caching
    storage_account_type = module.common.storage_account_type
  }

  dynamic "plan" {
    for_each = local.custom_image_condition ? [] : [1]
    content {
      name = module.common.vm_os_sku
      publisher = module.common.publisher
      product = module.common.vm_os_offer
    }
  }

  computer_name_prefix = lower(var.vmss_name)
  admin_username = module.common.admin_username
  admin_password = module.common.admin_password
  custom_data = base64encode(templatefile("${path.module}/cloud-init.sh", {
    installation_type = module.common.installation_type
    allow_upload_download = module.common.allow_upload_download
    os_version = module.common.os_version
    template_name = module.common.template_name
    template_version = module.common.template_version
    template_type = "terraform"
    is_blink = module.common.is_blink
    bootstrap_script64 = base64encode(var.bootstrap_script)
    location = module.common.resource_group_location
    sic_key = var.sic_key
    vnet = data.azurerm_subnet.frontend.address_prefixes[0]
    enable_custom_metrics = var.enable_custom_metrics ? "yes" : "no"
    admin_shell = var.admin_shell
    serial_console_password_hash = var.serial_console_password_hash
    maintenance_mode_password_hash = var.maintenance_mode_password_hash
    }))


    disable_password_authentication = local.SSH_authentication_type_condition

    dynamic "admin_ssh_key" {
      for_each = local.SSH_authentication_type_condition ? [
        1] : []
      content {
        public_key = file("azure_public_key")
        username = "notused"
      }
    }


  boot_diagnostics {
    storage_account_uri = module.common.boot_diagnostics ? join(",", azurerm_storage_account.vm-boot-diagnostics-storage.*.primary_blob_endpoint) : ""
  }

  upgrade_mode = "Manual"

  network_interface {
     name = "eth0"
     primary = true
     enable_ip_forwarding = true
     enable_accelerated_networking = true
     network_security_group_id = module.network-security-group[0].network_security_group_id
     ip_configuration {
       name = "ipconfig1"
       subnet_id = data.azurerm_subnet.frontend.id
       load_balancer_backend_address_pool_ids = var.deployment_mode != "Internal" ? [azurerm_lb_backend_address_pool.frontend-lb-pool[0].id]: null
       primary = true
       public_ip_address {
         name = "${var.vmss_name}-public-ip"
         idle_timeout_in_minutes = 15
         domain_name_label = "${lower(var.vmss_name)}-dns-name"
       }
     }
 }

  network_interface {
     name = "eth1"
     primary = false
     enable_ip_forwarding = true
     enable_accelerated_networking = true
     ip_configuration {
       name = "ipconfig2"
       subnet_id = data.azurerm_subnet.backend.id
       load_balancer_backend_address_pool_ids = var.deployment_mode != "External" ? [azurerm_lb_backend_address_pool.backend-lb-pool[0].id] : null
       primary = true
     }
 }

  tags = var.management_interface == "eth0"?{
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-management-address = var.management_IP,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = var.source_image_vhd_uri
  }:{
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = local.management_ip_address_type,
    x-chkp-management-interface = local.management_interface_name,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = var.source_image_vhd_uri
  }
}

resource "azurerm_monitor_autoscale_setting" "vmss_settings" {
  depends_on = [azurerm_linux_virtual_machine_scale_set.vmss]
  name = var.vmss_name
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  target_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "Profile1"

    capacity {
      default = module.common.number_of_vm_instances
      minimum = var.minimum_number_of_vm_instances
      maximum = var.maximum_number_of_vm_instances
    }

    rule {
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "GreaterThan"
        threshold = 80
      }

      scale_action {
        direction = "Increase"
        type = "ChangeCount"
        value = "1"
        cooldown = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "LessThan"
        threshold = 60
      }

      scale_action {
        direction = "Decrease"
        type = "ChangeCount"
        value = "1"
        cooldown = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator = false
      send_to_subscription_co_administrator = false
      custom_emails = var.notification_email == "" ? [] : [var.notification_email]
    }
  }
}

resource "azurerm_role_assignment" "custom_metrics_role_assignment"{
  depends_on = [azurerm_linux_virtual_machine_scale_set.vmss]
  count = var.enable_custom_metrics ? 1 : 0
  role_definition_id = join("", ["/subscriptions/", var.subscription_id, "/providers/Microsoft.Authorization/roleDefinitions/", "3913510d-42f4-4e42-8a64-420c390055eb"])
  principal_id = lookup(azurerm_linux_virtual_machine_scale_set.vmss.identity[0], "principal_id")
  scope = module.common.resource_group_id
  lifecycle {
    ignore_changes = [
      role_definition_id, principal_id
    ]
  }
}
