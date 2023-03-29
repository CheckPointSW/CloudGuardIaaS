// --- VPC Network Configuration ---
variable "vpc_name" {
  type = string
  description = "The name of the VPC"
default = "cp-vpc"
}
variable "vpc_cidr" {
  type = string
  description = "The CIDR block of the VPC"
default = "10.0.0.0/16"
}
variable "public_vswitchs_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"us-east-1a\" = 1} ) "
}
variable "vswitchs_bit_length" {
  type = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a vswitchs_bit_length value is 4, the resulting vswitch address will have length /20"
}
// --- ECS Instance Configuration ---
variable "instance_name" {
  type = string
  description = "AliCloud instance name to launch"
  default = "CP-Management-tf"
}
variable "instance_type" {
  type = string
  description = ""
  default ="ecs.g6e.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "management"
  instance_type = var.instance_type
}
variable "key_name" {
  type = string
  description = "The ECS Key Pair name to allow SSH access to the instances"
}
variable "allocate_and_associate_eip" {
  type = bool
  description = "When set to 'true', an elastic IP will be allocated and associated with the launched instance"
  default = true
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
variable "disk_category" {
  type = string
  description = "(Optional) Category of the ECS disk"
  default = "cloud_essd"
}
variable "ram_role_name" {
  type = string
  description = "RAM role name to attach to the instance profile"
  default = ""
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Management ECS Instance"
default = {}
}
// --- Check Point Settings ---
variable "version_license" {
  type = string
  description = "version and license"
  default = "R81-BYOL"
}
module "validate_management_version" {
  source = "../modules/common/version_license"

  chkp_type = "management"
  version_license = var.version_license
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}
variable "hostname" {
  type = string
  description = "(Optional)"
  default = ""
}

// --- Security Management Server Settings ---
variable "is_primary_management" {
  type = bool
  description = "true/false. Determines if this is the primary management server or not"
  default = true
}
variable "SICKey" {
  type = string
  description = "Mandatory only when deploying a secondary Management Server, the Secure Internal Communication key creates trusted connections between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
  default = ""
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "gateway_management" {
  type = string
  description = "Select 'Over the internet' if any of the gateways you wish to manage are not directly accessed via their private IP address"
  default = "Locally managed"
}
variable "admin_cidr" {
  type = string
  description = "(CIDR) Allow web, SSH, and graphical clients only from this network to communicate with the Management Server"
}
variable "gateway_addresses" {
  type = string
  description = "(CIDR) Allow gateways only from this network to communicate with the Management Server"
}
variable "primary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol primary server"
  default = ""
}
variable "secondary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol secondary server"
  default = ""
}
variable "bootstrap_script" {
  type = string
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}