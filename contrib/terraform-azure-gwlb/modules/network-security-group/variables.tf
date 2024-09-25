variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "location" {
  type = string
  description = "The location/region where Network Security Group will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "security_group_name" {
  description = "Network Security Group name"
  default     = "nsg"
}

variable "tags" {
  description = "The tags to associate with Network Security Group"
  type        = map(string)
  default     = {}
}

# Security Rules definition

variable "security_rules" {
  description = "Security rules for the Network Security Group using this format name = [priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix, description]"
  type    = list(any)
  default = []
}

variable "source_address_prefix" {
  description = "Source address prefix to be applied to all rules"
  type    = list(string)
  default = ["*"]
  # Example ["10.0.3.0/24"] or ["VirtualNetwork"]
}

variable "destination_address_prefix" {
  description = "Destination address prefix to be applied to all rules"
  type = list(string)
  default = ["*"]
  # Example ["10.0.3.0/32","10.0.3.128/32"] or ["VirtualNetwork"]
}

