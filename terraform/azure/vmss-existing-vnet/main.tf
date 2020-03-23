provider "azurerm" {
  version = "=1.44.0"

  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
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

//********************** Load Balancers **************************//
resource "azurerm_public_ip" "public-ip-lb" {
    name = "${var.vmss_name}-app-1"
    location = module.common.resource_group_location
    resource_group_name = module.common.resource_group_name
    allocation_method = var.vnet_allocation_method
    sku = var.sku
}

resource "azurerm_lb" "frontend-lb" {
 depends_on = [azurerm_public_ip.public-ip-lb]
 name = "frontend-lb"
 location = module.common.resource_group_location
 resource_group_name = module.common.resource_group_name
 sku = var.sku

 frontend_ip_configuration {
   name = "${var.vmss_name}-app-1"
   public_ip_address_id = azurerm_public_ip.public-ip-lb.id
 }
}

resource "azurerm_lb_backend_address_pool" "frontend-lb-pool" {
 resource_group_name = module.common.resource_group_name
 loadbalancer_id = azurerm_lb.frontend-lb.id
 name = "${var.vmss_name}-app-1"
}

resource "azurerm_lb" "backend-lb" {
 name = "backend-lb"
 location = module.common.resource_group_location
 resource_group_name = module.common.resource_group_name
 sku = var.sku
 frontend_ip_configuration {
   name = "backend-lb"
   subnet_id = data.azurerm_subnet.backend.id
   private_ip_address_allocation = "Static"
   private_ip_address = cidrhost(data.azurerm_subnet.backend.address_prefix,var.backend_lb_IP_address)
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
  name = count.index == 0 ? "${var.vmss_name}-app-1" : "backend-lb"
  protocol = var.lb_probe_protocol
  port = var.lb_probe_port
  interval_in_seconds = var.lb_probe_interval
  number_of_probes = var.lb_probe_unhealthy_threshold
}

resource "azurerm_lb_rule" "lbnatrule" {
  depends_on = [azurerm_lb.frontend-lb,azurerm_lb_probe.azure_lb_healprob,azurerm_lb.backend-lb]
  count = 2
  resource_group_name = module.common.resource_group_name
  loadbalancer_id = count.index == 0 ? azurerm_lb.frontend-lb.id : azurerm_lb.backend-lb.id
  name = count.index == 0 ? "${var.vmss_name}-app-1" : "backend-lb"
  protocol = count.index == 0 ? "Tcp" : "All"
  frontend_port = count.index == 0 ? var.frontend_port : "0"
  backend_port = count.index == 0 ? var.backend_port : "0"
  backend_address_pool_id = count.index == 0 ? azurerm_lb_backend_address_pool.frontend-lb-pool.id : azurerm_lb_backend_address_pool.backend-lb-pool.id
  frontend_ip_configuration_name = count.index == 0 ? azurerm_lb.frontend-lb.frontend_ip_configuration[0].name : azurerm_lb.backend-lb.frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.azure_lb_healprob[count.index].id
  load_distribution = count.index == 0 ? var.frontend_load_distribution : var.backend_load_distribution
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

}

//********************** Virtual Machines **************************//
resource "azurerm_virtual_machine_scale_set" "vmss" {
  name = var.vmss_name
  location = module.common.resource_group_location
  resource_group_name = module.common.resource_group_name
  zones = [var.availability_zones_num]
  overprovision = false

  storage_profile_image_reference {
    publisher = module.common.publisher
    offer = module.common.vm_os_offer
    sku = module.common.vm_os_sku
    version = module.common.vm_os_version
  }

  storage_profile_os_disk {
    create_option = module.common.storage_os_disk_create_option
    caching = module.common.storage_os_disk_caching
    managed_disk_type = module.common.storage_account_type
  }

  plan {
    name = module.common.vm_os_sku
    publisher = module.common.publisher
    product = module.common.vm_os_offer
  }

  os_profile {
    computer_name_prefix  = var.vmss_name
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
      vnet=data.azurerm_subnet.frontend.address_prefix
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

  upgrade_policy_mode = "Manual"

  network_profile {
     name = "eth0"
     primary = true
     ip_forwarding = false
     accelerated_networking = true
     ip_configuration {
       name = "ipconfig1"
       subnet_id = data.azurerm_subnet.frontend.id
       load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.frontend-lb-pool.id]
       primary = true
     }
 }

  network_profile {
     name = "eth1"
     primary = false
     ip_forwarding = true
     accelerated_networking = true
     ip_configuration {
       name = "ipconfig2"
       subnet_id = data.azurerm_subnet.backend.id
       load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend-lb-pool.id]
       primary = true
     }
 }
  sku {
    capacity = var.number_of_vm_instances
    name = module.common.vm_size
    tier = "Standard"
  }

  tags = var.management_interface == "eth0"?{
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = "private",
    x-chkp-management-interface = var.management_interface,
    x-chkp-management-address = var.management_IP,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = "noCustomUri"
  }:{
    x-chkp-management = var.management_name,
    x-chkp-template = var.configuration_template_name,
    x-chkp-ip-address = "private",
    x-chkp-management-interface = var.management_interface,
    x-chkp-topology = "eth0:external,eth1:internal",
    x-chkp-anti-spoofing = "eth0:false,eth1:false",
    x-chkp-srcImageUri = "noCustomUri"
  }
}

resource "azurerm_monitor_autoscale_setting" "vmss_settings" {
  depends_on = [azurerm_virtual_machine_scale_set.vmss]
  name = var.vmss_name
  resource_group_name = module.common.resource_group_name
  location = module.common.resource_group_location
  target_resource_id  = azurerm_virtual_machine_scale_set.vmss.id

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
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
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
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
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
