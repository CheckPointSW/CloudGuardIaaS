//********************** Basic Configuration **************************//
resource "azurerm_resource_group" "managed-app-rg" {
  name     = var.resource-group-name
  location = var.location
}

data "azurerm_virtual_hub" "vwan-hub" {
  name                = var.vwan-hub-name
  resource_group_name = var.vwan-hub-resource-group
}

//********************** Image Version **************************//

data "external" "az_access_token" {
  count = var.authentication_method == "Azure CLI" ? 1 : 0
  program = ["az", "account", "get-access-token", "--resource=https://management.azure.com", "--query={accessToken: accessToken}", "--output=json"]
}

data "http" "azure_auth" {
  count = var.authentication_method == "Service Principal" ? 1 : 0
  url    = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/token"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/x-www-form-urlencoded"
  }
  request_body = "grant_type=client_credentials&client_id=${var.client_id}&client_secret=${var.client_secret}&scope=https://management.azure.com/.default"
}

locals {
  access_token = var.authentication_method == "Service Principal" ? jsondecode(data.http.azure_auth[0].response_body).access_token : data.external.az_access_token[0].result.accessToken
}

data "http" "image-versions" {
  method = "GET"
  url = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.Network/networkVirtualApplianceSKUs/checkpoint${var.license-type == "Full Package (NGTX + S1C)" ? "-ngtx" : var.license-type == "Full Package Premium (NGTX + S1C++)" ? "-premium" : ""}?api-version=2020-05-01"
  request_headers = {
    Accept = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

locals {
      image_versions = tolist([for version in jsondecode(data.http.image-versions.response_body).properties.availableVersions : version if substr(version, 0, 4) == substr(lower(length(var.os-version) > 3 ? var.os-version : "${var.os-version}00"), 1, 4)])
      routing_intent-internet-policy = {
        "name": "InternetTraffic",
        "destinations": [
          "Internet"
        ],
        "nextHop": "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva-rg-name}/providers/Microsoft.Network/networkVirtualAppliances/${var.nva-name}"
      }
      routing_intent-private-policy = {
        "name": "PrivateTrafficPolicy",
        "destinations": [
          "PrivateTraffic"
        ],
        "nextHop": "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva-rg-name}/providers/Microsoft.Network/networkVirtualAppliances/${var.nva-name}"
      }
      routing-intent-policies = var.routing-intent-internet-traffic == "yes" ? (var.routing-intent-private-traffic == "yes" ? tolist([local.routing_intent-internet-policy, local.routing_intent-private-policy]) : tolist([local.routing_intent-internet-policy])) : (var.routing-intent-private-traffic == "yes" ? tolist([local.routing_intent-private-policy]) : [])
      public_ip_resource_group = "/subscriptions/${var.subscription_id}/resourceGroups/${var.new-public-ip == "yes" ? azurerm_resource_group.managed-app-rg.name : var.existing-public-ip != "" ? split("/", var.existing-public-ip)[4] : ""}"
}

//********************** Marketplace Terms & Solution Registration **************************//
data "http" "accept-marketplace-terms-existing-agreement" {
  method = "GET"
  url = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.MarketplaceOrdering/agreements/checkpoint/offers/cp-vwan-managed-app/plans/vwan-app?api-version=2021-01-01"
  request_headers = {
    Accept = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

resource "azurerm_marketplace_agreement" "accept-marketplace-terms" {
  count = can(jsondecode(data.http.accept-marketplace-terms-existing-agreement.response_body).id) ? (jsondecode(data.http.accept-marketplace-terms-existing-agreement.response_body).properties.state == "Active" ? 0 : 1) : 1
  publisher = "checkpoint"
  offer     = "cp-vwan-managed-app"
  plan      = "vwan-app"
}

data "http" "azurerm_resource_provider_registration-exist" {
  method = "GET"
  url = "https://management.azure.com/subscriptions/${var.subscription_id}/providers/Microsoft.Solutions?api-version=2021-01-01"
  request_headers = {
    Accept = "application/json"
    "Authorization" = "Bearer ${local.access_token}"
  }
}

resource "azurerm_resource_provider_registration" "solutions" {
  count = jsondecode(data.http.azurerm_resource_provider_registration-exist.response_body).registrationState == "Registered" ? 0 : 1
  name = "Microsoft.Solutions"
}

//********************** Managed Identiy **************************//
resource "azurerm_user_assigned_identity" "managed_app_identiy" {
  location            = azurerm_resource_group.managed-app-rg.location
  name                = "managed_app_identiy"
  resource_group_name = azurerm_resource_group.managed-app-rg.name
}

resource "azurerm_role_assignment" "reader" {
  depends_on = [azurerm_user_assigned_identity.managed_app_identiy]
  scope                = data.azurerm_virtual_hub.vwan-hub.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.managed_app_identiy.principal_id
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = azurerm_resource_group.managed-app-rg.name
  }
  byte_length = 8
}

resource "azurerm_role_definition" "public-ip-join-role" {
  count       = var.new-public-ip == "yes" || length(var.existing-public-ip) > 0 ? 1 : 0
  name        = "Managed Application Public IP Join Role - ${random_id.randomId.hex}"
  scope       = local.public_ip_resource_group
  permissions {
    actions     = ["Microsoft.Network/publicIPAddresses/join/action"]
    not_actions = []
  }
  assignable_scopes = [local.public_ip_resource_group]
}

resource "azurerm_role_assignment" "public-ip-join-role-assignment" {
  count    = var.new-public-ip == "yes" || length(var.existing-public-ip) > 0 ? 1 : 0
  scope    = local.public_ip_resource_group
  role_definition_id = azurerm_role_definition.public-ip-join-role[0].role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.managed_app_identiy.principal_id
}

//********************** Managed Application Configuration **************************//
resource "azapi_resource" "managed-app" {
  depends_on = [azurerm_marketplace_agreement.accept-marketplace-terms, azurerm_resource_provider_registration.solutions]
  type      = "Microsoft.Solutions/applications@2019-07-01"
  name      = var.managed-app-name
  location  = azurerm_resource_group.managed-app-rg.location
  parent_id = azurerm_resource_group.managed-app-rg.id
  body = {
	kind = "MarketPlace",
	plan = {
		name      = "vwan-app"
		product   = "cp-vwan-managed-app"
		publisher = "checkpoint"
		version   = "1.0.22"
	},
	identity = {
		type = "UserAssigned"
		userAssignedIdentities = {
        (azurerm_user_assigned_identity.managed_app_identiy.id) = {}
      }
	},
	properties = {
		parameters = {
			location = {
			  value = azurerm_resource_group.managed-app-rg.location
			},
			hubId = {
			  value = data.azurerm_virtual_hub.vwan-hub.id
			},
			osVersion = {
			  value = var.os-version
			},
			LicenseType = {
			  value = var.license-type
			},
			imageVersion = {
			  value = element(local.image_versions, length(local.image_versions) -1)
			},
			scaleUnit = {
			  value = var.scale-unit
			},
			bootstrapScript = {
			  value = var.bootstrap-script
			},
			adminShell = {
			  value = var.admin-shell
			},
			sicKey = {
			  value = var.sic-key
			},
			sshPublicKey = {
			  value = var.ssh-public-key
			},
			BGP = {
			  value = var.bgp-asn
			},
			NVA = {
			  value = var.nva-name
			},
			customMetrics = {
			  value = var.custom-metrics
			},
			hubASN = {
			  value = data.azurerm_virtual_hub.vwan-hub.virtual_router_asn
			},
			hubPeers = {
			  value = data.azurerm_virtual_hub.vwan-hub.virtual_router_ips
			},
			smart1CloudTokenA = {
			  value = var.smart1-cloud-token-a
			},
			smart1CloudTokenB = {
			  value = var.smart1-cloud-token-b
			},
			smart1CloudTokenC = {
			  value = var.smart1-cloud-token-c
			},
			smart1CloudTokenD = {
			  value = var.smart1-cloud-token-d
			},
			smart1CloudTokenE = {
			  value = var.smart1-cloud-token-e
			},
			publicIPIngress = {
			  value = (var.new-public-ip == "yes" || length(var.existing-public-ip) > 0) ? "yes" : "no"
			},
			createNewIPIngress = {
			  value = var.new-public-ip
			},
			ipIngressExistingResourceId = {
			  value = var.existing-public-ip
			},
			templateName = {
			  value = "wan_terraform"
			}
		},
		managedResourceGroupId = "/subscriptions/${var.subscription_id}/resourcegroups/${var.nva-rg-name}"
	}
  }
}

//********************** Routing Intent **************************//

data "azapi_resource_list" "existing_routing_intent" {
  type      = "Microsoft.Network/virtualHubs/routingIntent@2024-05-01"
  parent_id = data.azurerm_virtual_hub.vwan-hub.id
  response_export_values = {
      "values" = "value[].{routingPolicies: properties.routingPolicies}"
	}

}

locals {
  routing_intent_exists = length([for intent in data.azapi_resource_list.existing_routing_intent.output.values : intent]) > 0
  existing_policies = try(data.azapi_resource_list.existing_routing_intent.output.values[0].routingPolicies, [])
  merged_policies = concat(
    local.routing-intent-policies,
    [for policy in local.existing_policies : policy if !contains([for p in local.routing-intent-policies : p.destinations[0]], policy.destinations[0])]
  )
}

resource "azapi_resource" "routing_intent" {
  count = length(local.routing-intent-policies) != 0 && !local.routing_intent_exists ? 1 : 0
  depends_on = [azapi_resource.managed-app]
  type      = "Microsoft.Network/virtualHubs/routingIntent@2024-05-01"
  name      = "hubRoutingIntent"
  parent_id = data.azurerm_virtual_hub.vwan-hub.id

  body = {
    properties = {
      routingPolicies = local.routing-intent-policies
    }
  }
}

resource "azapi_update_resource" "update_routing_intent" {
  count = length(local.routing-intent-policies) != 0 && local.routing_intent_exists ? 1 : 0
  depends_on = [azapi_resource.managed-app]
  type = "Microsoft.Network/virtualHubs/routingIntent@2024-05-01"
  resource_id = "${data.azurerm_virtual_hub.vwan-hub.id}/routingIntent/hubRoutingIntent"

  body = {
    properties = {
      routingPolicies = local.merged_policies
    }
  }
}
