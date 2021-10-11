data "alicloud_regions" "current" {
  current = true
}
locals {
  region = data.alicloud_regions.current.regions.0.id
}

// --- Version and license ---
variable "chkp_type" {
  type = string
  description = "The Check Point machine type"
  default = "gateway"
}

variable "version_license" {
  type = string
  description = "Version and license"
}

