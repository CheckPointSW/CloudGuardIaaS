// Module: Check Point CloudGuard Network Security Cluster into an existing VPC

// --- AWS Provider ---
variable "region" {
  type = string
  description = "AWS region"
  default = ""
}
variable "access_key" {
  type = string
  description = "AWS access key"
  default = ""
}
variable "secret_key" {
  type = string
  description = "AWS secret key"
  default = ""
}

// ---VPC Network Configuration ---
variable "vpc_cidr" {
  type = string
  description = "The CIDR block of the VPC"
  default = "10.0.0.0/16"
}
variable "public_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 1} ) "
}
resource "null_resource" "tgw_availability_zones_validation1" {
  count = length(var.public_subnets_map) == 2 ? 0 : "variable public_subnets_map size must be equal to variable 2"
}
variable "private_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 1 pair.  (e.g. {\"us-east-1a\" = 2} ) "
}
resource "null_resource" "tgw_availability_zones_validation2" {
  count = length(var.private_subnets_map) == 2 ? 0 : "variable private_subnets_map size must be equal to variable 2"
}
variable "tgw_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number} for the tgw subnets. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 3} ) "
}
resource "null_resource" "tgw_availability_zones_validation3" {
  count = length(var.tgw_subnets_map) == 2 ? 0 : "variable tgw_subnets_map size must be equal to variable 2"
}
variable "subnets_bit_length" {
  type = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a subnets_bit_length value of 4, the resulting subnet address will have length /20"
}


// --- EC2 Instance Configuration ---
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Cluster-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "c5.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}
variable "allocate_and_associate_eip" {
  type = bool
  description = "If set to true, an elastic IP will be allocated and associated with each cluster member, in addition to the shared cluster Elastic IP"
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
variable "volume_type" {
  type = string
  description = "General Purpose SSD Volume Type"
  default = "gp3"
}
variable "volume_encryption" {
  type = string
  description = "KMS or CMK key Identifier: Use key ID, alias or ARN. Key alias should be prefixed with 'alias/' (e.g. for KMS default alias 'aws/ebs' - insert 'alias/aws/ebs')"
  default = "alias/aws/ebs"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable SSH connection over AWS web console"
  default = false
}
variable "disable_instance_termination" {
  type = bool
  description = "Prevents an instance from accidental termination"
  default = false
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Gateway EC2 Instances"
  default = {}
}
variable "predefined_role" {
  type = string
  description = "(Optional) A predefined IAM role to attach to the cluster profile"
  default = ""
}

// --- Check Point Settings ---
variable "gateway_version" {
  type = string
  description =  "Gateway version and license"
  default = "R81.20-BYOL"
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
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}

// --- Quick connect to Smart-1 Cloud (Recommended) ---
variable "memberAToken" {
  type = string
  description = "Follow the instructions in sk180501 to quickly connect this Cross AZ Cluster to Smart-1 Cloud."
}
variable "memberBToken" {
  type = string
  description = "Follow the instructions in sk180501 to quickly connect this Cross AZ Cluster to Smart-1 Cloud."
}

// --- Advanced Settings ---
variable "resources_tag_name" {
  type = string
  description = "(Optional) Name tag prefix of the resources"
  default = ""
}
variable "gateway_hostname" {
  type = string
  description = "(Optional) The host name will be appended with member-a/b accordingly"
  default = ""
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics"
  default = false
}
variable "gateway_bootstrap_script" {
  type = string
  description = "(Optional) An optional script with semicolon (;) separated commands to run on the initial boot"
  default = ""
}
variable "primary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol primary server"
  default = "169.254.169.123"
}
variable "secondary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol secondary server"
  default = "0.pool.ntp.org"
}
