variable "protocol" {
  type = string
  description = "The IP protocol to which this rule applies."
}
variable "source_ranges" {
  type = list(string)
  description = "(Optional) Source IP ranges for the protocol traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable this protocol traffic."
  default = []
}
variable "rule_name" {
  type = string
  description = "Firewall rule name."
}
variable "network" {
  type = list(string)
  description = "The name or self_link of the network to attach this firewall to."
}