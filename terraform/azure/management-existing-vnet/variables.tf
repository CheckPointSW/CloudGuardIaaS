//********************** Basic Configuration Variables **************************//
variable "mgmt_name" {
  description = "Management name"
  type = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "location" {
  description = "The location/region where resource will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

//********************** Virtual Machine Instances Variables **************************//
variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  default = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Macine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type = string
}
locals { // locals for 'authentication_type' allowed values
  authentication_type_allowed_values = [
    "Password",
    "SSH Public Key"
  ]
  // will fail if [var.authentication_type] is invalid:
  validate_authentication_type_value = index(local.authentication_type_allowed_values, var.authentication_type)
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type(mgmt, ha, vmss)"
  type = string
  default = "mgmt_terraform"
}

variable "template_version" {
  description = "Template version. It is reccomended to always use the latest template version"
  type = string
  default = "20201109"
}

variable "installation_type" {
  description = "Installaiton type"
  type = string
  default = "management"
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type = string
}

variable "disk_size" {
  description = "Storage data disk size size(GB).Select a number between 100 and 3995"
  type = string
}

variable "os_version" {
  description = "GAIA OS version"
  type = string
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
}

variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8030, check-point-cg-r8040, check-point-cg-r81"
  type = string
}

variable "allow_upload_download" {
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  type = bool
}

//********************** Natworking Variables **************************//
variable "vnet_name" {
  description = "Virtual Network name"
  type = string
}

variable "management_subnet_name" {
  description = "management subnet name"
  type = string
}

variable "subnet_1st_Address" {
  description = "The first available address of the subnet"
  type = string
}

variable "vnet_resource_group" {
  description = "Resource group of existing vnet"
  type = string
}

variable "vnet_allocation_method" {
  description = "IP address allocation method"
  type = string
  default = "Static"
}

variable "management_GUI_client_network" {
  description = "Allowed GUI clients - GUI clients network CIDR"
  type = string
}

locals {
  regex_valid_management_GUI_client_network = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))$"
  // Will fail if var.management_GUI_client_network is invalid
  regex_management_GUI_client_network = regex(local.regex_valid_management_GUI_client_network, var.management_GUI_client_network) == var.management_GUI_client_network ? 0 : "Variable [management_GUI_client_network] must be a valid IPv4 network CIDR."

  regex_valid_subnet_1st_Address = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
  // Will fail if var.subnet_1st_Address is invalid
  regex_subnet_1st_Address = regex(local.regex_valid_subnet_1st_Address, var.subnet_1st_Address) == var.subnet_1st_Address ? 0 : "Variable [subnet_1st_Address] must be a valid address."
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  default = ""
  type = string
  #example:
  #"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
}

//********************** Credentials **************************//
variable "tenant_id" {
  description = "Tenant ID"
  type = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type = string
}

variable "client_id" {
  description = "Aplication ID(Client ID)"
  type = string
}

variable "client_secret" {
  description = "A secret string that the application uses to prove its identity when requesting a token. Also can be referred to as application password."
  type = string
}
