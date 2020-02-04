data "azurerm_resource_group" "test" {
  name = "RG-ClusterName-Prod"
}

data "azurerm_network_interface" "CpCluster2-eth0" {
  name = "NewGW-ClusterName-eth0"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
}

data "azurerm_network_interface" "CpCluster2-eth1" {
  name = "NewGW-ClusterName-eth1"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
}

data "azurerm_storage_account" "bootdiagivrloyuspqs3m" {
  name =  "bootdiagrfak4kbvsxjge"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
}

data "azurerm_availability_set" "ClusterName-AvailabilitySet" {
  name = "ClusterName-AvailabilitySet"
  resource_group_name   = "${data.azurerm_resource_group.test.name}"
}

data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

# Create virtual machine 2 
resource "azurerm_virtual_machine" "NewGW" {
    name                  = "NewGW"
    location            = var.location
    resource_group_name   = "${data.azurerm_resource_group.test.name}"
    network_interface_ids = ["${data.azurerm_network_interface.CpCluster2-eth0.id}","${data.azurerm_network_interface.CpCluster2-eth1.id}"]
    primary_network_interface_id = "${data.azurerm_network_interface.CpCluster2-eth0.id}"
    vm_size               = "Standard_D4s_v3" 
	availability_set_id		= "${data.azurerm_availability_set.ClusterName-AvailabilitySet.id}"

    storage_os_disk {
        name              = "NewGW"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
		disk_size_gb 	  = "200" 
    }

/*
    storage_image_reference {
        publisher = "checkpoint"
        offer     = "check-point-vsec-r80-blink-v2"
        sku       = "sg-byol"
        version   = "8010.90034.0373"
    }
*/

	storage_image_reference {
		id = "${data.azurerm_image.custom.id}"
	}

/* not necesasry when calling from custom image
    plan {
        name = "sg-byol"
        publisher = "checkpoint"
        product = "check-point-vsec-r80-blink-v2"
        }
*/       
# For Check Point user notused must be used
    os_profile {
        computer_name = "NewGW"
        admin_username       = "notused"
        admin_password       = var.admin_password
    
# formatting is crucial here. Do not change 
/* not used for this image 
        custom_data = <<-EOF
    #!/usr/bin/python /etc/cloud_config.py
    
    installationType = gateway \
    allowUploadDownload = True \
    osVersion = R80.10 \
    templateName = cluster \
    isBlink = True \
    templateVersion = 20191003 \
    bootstrapScript64 =" "\
    location = ${var.location} \
    sicKey = ${var.sickey} \
    vnet ="${var.backend}"
    EOF
 */
  }
   
    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${data.azurerm_storage_account.bootdiagivrloyuspqs3m.primary_blob_endpoint}"
    }

tags = {
        provider = "30DE18BC-F9F6-4F22-9D30-54B8E74CFD5F"        
    }  

}
