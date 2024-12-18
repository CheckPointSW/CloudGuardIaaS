variable "vpc_cidr" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "public_vswitchs_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"cn-hangzhou-e\" = 1} ) "
}
variable "management_vswitchs_map" {
  type = map(string)
  description = "(Optional) A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"cn-hangzhou-e\" = 3} ) "
  default = {}
}
variable "private_vswitchs_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"cn-hangzhou-f\" = 3} ) "
}
variable "vswitchs_bit_length" {
  type        = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a vswitchs_bit_length value is 4, the resulting vswitch address will have length /20"
}
