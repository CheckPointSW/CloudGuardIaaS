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
variable "private_vswitchs_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"us-east-1a\" = 2} ) "

}
variable "vswitchs_bit_length" {
  type = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a vswitchs_bit_length value is 4, the resulting vswitch address will have length /20"
}

// --- ECS Instance Configuration ---
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
default = "Check-Point-Gateway-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Secutiry Gateways"
default = "ecs.g5ne.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "key_name" {
  type = string
  description = "The ECS Key Pair name to allow SSH access to the instance"
}
variable "allocate_and_associate_eip" {
  type = bool
  description = "If set to TRUE, an elastic IP will be allocated and associated with the launched instance"
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
  default = "cloud_efficiency"
}
variable "ram_role_name" {
  type = string
  description = "RAM role name to attach to the instance profile"
  default = ""
}
resource "null_resource" "volume_size_too_small" {
  // Volume Size validation - resource will not be created if the volume size is smaller than 100
  count = var.volume_size >= 100 ? 0 : "volume_size must be at least 100"
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Gateway ECS Instance"
default = {}
}

// --- Check Point Settings ---
variable "gateway_version" {
  type = string
  description =  "Gateway version and license"
  default = "R81-BYOL"
}
module "validate_gateway_version" {
  source = "../modules/common/version_license"

  chkp_type = "gateway"
  version_license = var.gateway_version
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
default = "/etc/cli.sh"
}
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
}
variable "gateway_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash)"
default = ""
}

// --- Advanced Settings ---
variable "resources_tag_name" {
  type = string
  description = "(Optional)"
  default = ""
}
variable "gateway_hostname" {
  type = string
  description = "(Optional)"
  default = ""
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
default = true
}
variable "gateway_bootstrap_script" {
  type = string
  description = "(Optional) An optional script with semicolon (;) separated commands to run on the initial boot"
  default = ""
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