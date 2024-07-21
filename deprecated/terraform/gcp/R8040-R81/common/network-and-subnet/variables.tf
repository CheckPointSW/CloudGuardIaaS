variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-ha"
}
variable "type" {
  type = string
}
variable "network_cidr" {
  type = string
  description = "External subnet CIDR. If the variable's value is not empty double quotes, a new network will be created."
  default = "10.0.0.0/24"
}
variable "private_ip_google_access" {
  type = bool
  description = "When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access."
  default = true
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "network_name" {
  type = string
  description = "External network ID in the chosen zone. The network determines what network traffic the instance can access.If you have specified a CIDR block at var.network_cidr, this network name will not be used."
  default = ""
}