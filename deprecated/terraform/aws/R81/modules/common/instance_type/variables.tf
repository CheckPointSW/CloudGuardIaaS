variable "chkp_type" {
  type = string
  description = "The Check Point machine type"
  default = "gateway"
}
locals {
  type_allowed_values = [
    "gateway",
    "management",
    "mds",
    "standalone",
    "server"
  ]
  // Will fail if var.chkp_type is invalid
  validate_instance_type = index(local.type_allowed_values, var.chkp_type)
}

variable "instance_type" {
  type = string
  description = "AWS Instance type"
}

