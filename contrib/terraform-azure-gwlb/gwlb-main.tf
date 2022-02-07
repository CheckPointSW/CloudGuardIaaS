# Accept the agreement for the mgmt-byol for R80.40
resource "azurerm_marketplace_agreement" "gwlb-vmss-agreement" {
  count     = var.gwlb-vmss-agreement ? 0 : 1
  publisher = "checkpoint"
  offer     = "check-point-cg-r8110"
  plan      = "sg-byol"
}

# Create gwlb resource group
resource "azurerm_resource_group" "rg-gwlb-vmss" {
  name      = "rg-${var.gwlb-name}"
  location  = var.location
}
resource "azurerm_resource_group_template_deployment" "template-deployment-gwlb" {
  name                = "${var.gwlb-name}-deploy"
  resource_group_name = azurerm_resource_group.rg-gwlb-vmss.name
  deployment_mode     = "Complete"

  template_content    = file("files/azure-gwlb-template.json")
  parameters_content  = <<PARAMETERS
  {
    "subscriptionId": {
        "value": "${var.azure-subscription}"
    },
    "location": {
        "value": "${var.location}"
    },
    "cloudGuardVersion": {
        "value": "R81.10 - Bring Your Own License"
    },
    "instanceCount": {
        "value": "${var.gwlb-vmss-min}"
    },
    "maxInstanceCount": {
        "value": "${var.gwlb-vmss-max}"
    },
    "managementServer": {
        "value": "${var.mgmt-name}"
    },
    "configurationTemplate": {
        "value": "az-${var.gwlb-name}"
    },
    "adminEmail": {
        "value": ""
    },
    "adminPassword": {
        "value": "${var.chkp-admin-pwd}"
    },
    "authenticationType": {
        "value": "password"
    },
    "sshPublicKey": {
        "value": ""
    },
    "vmName": {
        "value": "${var.gwlb-name}"
    },
    "vmSize": {
        "value": "${var.gwlb-size}"
    },
    "sicKey": {
        "value": "${var.chkp-sic}"
    },
    "virtualNetworkName": {
        "value": "${azurerm_virtual_network.vnet-north.name}"
    },
    "upgrading": {
        "value": "no"
    },
    "lbsTargetRGName": {
        "value": ""
    },
    "lbResourceId": {
        "value": ""
    },
    "lbTargetBEAddressPoolName": {
        "value": ""
    },
    "virtualNetworkAddressPrefix": {
        "value": "${azurerm_virtual_network.vnet-north.address_space[0]}"
    },
    "subnet1Name": {
        "value": "${azurerm_subnet.net-north-gateways.name}"
    },
    "subnet1Prefix": {
        "value": "${azurerm_subnet.net-north-gateways.address_prefixes[0]}"
    },
    "subnet1StartAddress": {
        "value": "172.16.0.4"
    },
    "vnetNewOrExisting": {
        "value": "new"
    },
    "virtualNetworkExistingRGName": {
        "value": "${azurerm_virtual_network.vnet-north.resource_group_name}"
    },
    "bootstrapScript": {
        "value": ""
    },
    "allowDownloadFromUploadToCheckPoint": {
        "value": "true"
    },
    "instanceLevelPublicIP": {
        "value": "yes"
    },
    "mgmtInterfaceOpt1": {
        "value": "eth0-private"
    },
    "mgmtIPaddress": {
        "value": ""
    },
    "diskType": {
        "value": "Standard_LRS"
    },
    "appLoadDistribution": {
        "value": "Default"
    },
    "sourceImageVhdUri": {
        "value": "noCustomUri"
    },
    "availabilityZonesNum": {
        "value": 0
    },
    "customMetrics": {
        "value": "yes"
    },
    "rbacGuid": {
        "value": "1996c614-4e24-41f8-9515-fd3f99a814d2"
    },
    "vxlanTunnelExternalIdentifier": {
        "value": 801
    },
    "vxlanTunnelExternalPort": {
        "value": 2001
    },
    "vxlanTunnelInternalIdentifier": {
        "value": 800
    },
    "vxlanTunnelInternalPort": {
        "value": 2000
    }
  }
  PARAMETERS 
  depends_on = [azurerm_resource_group.rg-gwlb-vmss,azurerm_subnet.net-north-gateways]
}

data "azurerm_lb" "gateway-lb" {
  name                = "gateway-lb"
  resource_group_name = azurerm_resource_group.rg-gwlb-vmss.name
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-gwlb]
}
data "azurerm_virtual_network" "vnet-north-gwlb" {
  name                = "vnet-north"
  resource_group_name = azurerm_resource_group.rg-gwlb-vmss.name
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-gwlb]
}
