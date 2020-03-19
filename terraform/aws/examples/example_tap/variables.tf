variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}
data "aws_region" "current" {
  name = var.region
}

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
variable "is_enable_instance_connect" {
  type = bool
  description = "Enable AWS Instance Connect - Ec2 Instance Connect is not supported with versions prior to R80.40"
  default = false
}

// --- Check Point Settings ---
variable "version_license" {
  type = string
  description =  "version and license"
  default = "R80.30-PAYG-NGTP-GW"
}
