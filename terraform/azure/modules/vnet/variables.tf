variable "vnet_name" {
  description = "Name of Virtual Network"
  type = string
  default     = "vnet01"
}

variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

variable "address_space" {
  description = "The address prefixes of the virtual network"
  type = string
  default     = "10.0.0.0/16"
}

variable "dns_servers" {
  description = " DNS servers to be used with a Virtual Network. If no values specified, this defaults to Azure DNS"
  type = list(string)
  default = []
}

variable "subnet_prefixes" {
  description = "The address prefixes to be used for subnets"
  type = list(string)
  default     = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "subnet_names" {
  description = "A list of subnet names in a Virtual Network"
  type = list(string)
  default = ["Frontend","Backend"]
}

variable "tags" {
  description = "Tags to be associated with Virtual Network and subnets"
  type = map(string)
  default = {}
}
variable "nsg_id" {
  description = "Network security group to be associated with a Virtual Network and subnets"
  type = string
}

variable "allocation_method" {
  description = "IP address allocation method"
  type = string
  default = "Static"
}

locals { // locals for 'allocation_method' allowed values
  allocation_method_allowed_values = [
    "Static"
  ]
  // will fail if [var.allocation_method] is invalid:
  validate_method_allowed_value = index(local.allocation_method_allowed_values, var.allocation_method)
}