
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
  description = "The gateway registration key to the TAP cloud"
}
variable "vxlan_ids" {
  type = list(number)
  description = "(Optional) list of VXLAN IDs (numbers) for mirroring sessions - Predefine VTEP numbers"
  default = []
}
variable "blacklist_tags" {
  type = map(string)
  description = "<key,value> map: each pair represents a tag which will blacklist an instance from TAP creation"
  default = {}
}
variable "schedule_scan_period" {
  type = number
  description = "(minutes) Lambda will scan the VPC every X minutes for tap status"
  default = 10
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
locals { // locals for 'instance_type' allowed values
  instance_type_allowed_values = [
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "c5.9xlarge",
    "c5.18xlarge"
  ]
  validate_instance_type = index(local.instance_type_allowed_values, var.instance_type) // will fail if var.instance_type is invalid
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}
variable "password_hash" {
  type = string
  description = "Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash)"
}
variable "is_allocate_and_associate_elastic_ip" {
  type = bool
  description = "If set to TRUE, an elastic IP will be allocated and associated with the launched instance"
  default = true
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
resource "null_resource" "volume_size_too_small" {
  // Volume Size validation - resource will not be created if the volume size is smaller than 100
  count = var.volume_size >= 100 ? 0 : "volume_size must be at least 100"
}
variable "is_enable_instance_connect" {
  type = bool
  description = "Enable AWS Instance Connect - Ec2 Instance Connect is not supported with versions prior to R80.40"
  default = false
}

// --- Check Point Settings ---
variable "version_license" {
  type = string
  description =  "version and license"
  default = "R80.30-BYOL-GW"
}
locals { // locals for 'version and license' allowed values
  version_license_allowed_values = [
    "R80.30-BYOL-GW",
    "R80.30-PAYG-NGTP-GW",
    "R80.30-PAYG-NGTX-GW",
    "R80.40-BYOL-GW",
    "R80.40-PAYG-NGTP-GW",
    "R80.40-PAYG-NGTX-GW"
  ]
  validate_version_license = index(local.version_license_allowed_values, var.version_license) // will fail if var.version_license is invalid
}
