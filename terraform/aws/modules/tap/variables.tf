variable "region" {
  type = string
  description = "AWS region"
}
data "aws_region" "current" {
  name = var.region
}
variable "zone" {
  type = string
  description = "AWS availability zone for TAP per-zone deployment"
  default = "none"
}
variable "version_license" {
  type = string
  description = "CP version and license"
  default = "R80.40-PAYG-NGTP-GW"
}

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
  description = "VPC ID"
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
  description = "(Optional) Resources prefix tag (default TAP)"
  default = "TAP"
}

// --- TAP and Lambda Configuration ---
variable "registration_key" {
  type = string
  description = "The gateway registration key to Check Point NOW cloud"
}
variable "vxlan_id" {
  type = number
  description = "(Optional) VXLAN ID (number) for mirroring sessions - Predefined VTEP number (default 1)"
  default = 1
}
variable "schedule_scan_interval" {
  type = number
  description = "(Optional) Every (minutes) TAP Lambda will scan the VPC for TAP updates (default 10)"
  default = 10
}
variable "all_eni" {
  type = string
  description = "(Optional) Pass 'no' to TAP only main ENI of each instance (default yes)"
  default = "yes"
}
variable "blacklist_tags" {
  type = map(string)
  description = "Key value pairs of tag key and tag value. Instances with any of these tag pairs will not be TAPed"
  default = {}
}
variable "whitelist_tags" {
  type = map(string)
  description = "Key value pairs of tag key and tag value. Instances with any of these tag pairs will be TAPed"
  default = {}
}
variable "use_whitelist" {
  type = string
  description = "(Optional) Pass 'yes' to use whitelist instead of blacklist (default no)"
  default = "no"
}

// --- EC2 Instance Configuration ---
variable "instance_type" {
  type = string
  description = "(Optional) Instance type of TAP sensor (default c5.xlarge)"
  default = "c5.xlarge"
}
variable "key_pair_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to TAP sensor"
}
