variable "gateway_or_management" {
  type = string
  description = "gateway/management"
  default = "gateway"
}
locals {
  type_allowed_values = [
    "gateway",
    "management"
  ]
  // Will fail if var.instance_type is invalid
  validate_instance_type = index(local.type_allowed_values, var.gateway_or_management)
}

variable "instance_type" {
  type = string
  description = "AWS Instance type"
}

