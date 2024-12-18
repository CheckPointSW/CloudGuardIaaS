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
    "gwlb_gw"]
  // Will fail if var.chkp_type is invalid
  validate_chkp_type = index(local.type_allowed_values, var.chkp_type)
}

variable "version_license" {
  type = string
  description = "AWS Version license"
}

