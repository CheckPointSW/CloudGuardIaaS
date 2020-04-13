
// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "external_subnet_id" {
  type = string
  description = "The external subnet of the security gateway (internet access)"
}
variable "internal_subnet_id" {
  type = string
  description = "The internal subnet of the security gateway. This subnet will be connected to the mirrored sources."
}
variable "resources_tag_name" {
  type = string
  description = "(Optional) Resources prefix tag"
  default = ""
}

// --- TAP Configuration ---
variable "registration_key" {
  type = string
  description = "The gateway registration key to Check Point NOW cloud"
}
variable "vxlan_id" {
  type = number
  description = "(Optional) VXLAN ID (number) for mirroring sessions - Predefined VTEP number"
  default = 1
}
variable "blacklist_tags" {
  type = map(string)
  description = "Key value pairs of tag key and tag value. Instances with any of these tag pairs will not be TAPed"
  default = {}
}
variable "schedule_scan_interval" {
  type = number
  description = "(minutes) Lambda will scan the VPC every X minutes for TAP updates"
  default = 60
}

// --- EC2 Instance Configuration ---
variable "instance_name" {
  type = string
  description = "AWS instance name to launch"
  default = "CP-TAP-Gateway-tf"
}
variable "instance_type" {
  type = string
  default = "c5.xlarge"
}
module "validate_instance_type" {
  source = "../../modules/instance_type"

  chkp_type = "gateway"
  instance_type = var.instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}

// --- Check Point Settings ---
variable "version_license" {
  type = string
  description =  "version and license"
  default = "R80.40-PAYG-NGTX-GW"
}
