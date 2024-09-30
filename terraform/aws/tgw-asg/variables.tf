// Module: Check Point CloudGuard Network Transit Gateway Auto Scaling Group
// Deploy an Auto Scaling Group of CloudGuard Security Gateways for Transit Gateway with an optional Management Server into an existing VPC

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

// --- Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "gateways_subnets" {
  type = list(string)
  description = "Select at least 2 external subnets in the VPC. If you choose to deploy a Security Management Server it will be deployed in the first subnet"
}

// --- General Settings ---
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
  default = true
}
variable "enable_volume_encryption" {
  type = bool
  description = "Encrypt Environment instances volume with default AWS KMS key"
  default = true
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
variable "metadata_imdsv2_required" {
  type = bool
  description = "Set true to deploy the instance with metadata v2 token required"
  default = true
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}

// --- Check Point CloudGuard Network Security Gateways Auto Scaling Group Configuration ---
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Gateway"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "c6in.xlarge"
}
module "validate_gateway_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "gateways_min_group_size" {
  type = number
  description = "The minimal number of Security Gateways"
  default = 2
}
variable "gateways_max_group_size" {
  type = number
  description = "The maximal number of Security Gateways"
  default = 10
}
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
variable "gateway_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}
variable "gateway_maintenance_mode_password_hash" {
  description = "(optional) Check Point recommends setting Admin user's password and maintenance-mode password for recovery purposes. For R81.10 and below the Admin user's password is used also as maintenance-mode password. (To generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here)."
  type = string
  default = ""
}
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
}
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics"
  default = false
}
variable "asn" {
  type = string
  description = "The organization Autonomous System Number (ASN) that identifies the routing domain for the Security Gateways"
  default = "6500"
}

// --- Check Point CloudGuard Network Security Management Server Configuration ---
variable "management_deploy" {
  type = bool
  description = "Select 'false' to use an existing Security Management Server or to deploy one later and to ignore the other parameters of this section"
  default = true
}
variable "management_instance_type" {
  type = string
  description = "The EC2 instance type of the Security Management Server"
  default = "m5.xlarge"
}
module "validate_management_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "management"
  instance_type = var.management_instance_type
}
variable "management_version" {
  type = string
  description =  "The license to install on the Security Management Server"
  default = "R81.20-BYOL"
}
module "validate_management_version" {
  source = "../modules/common/version_license"

  chkp_type = "management"
  version_license = var.management_version
}
variable "management_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}
variable "management_maintenance_mode_password_hash" {
  description = "(optional) Check Point recommends setting Admin user's password and maintenance-mode password for recovery purposes. For R81.10 and below the Admin user's password is used also as maintenance-mode password. (To generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here)."
  type = string
  default = ""
}
variable "management_permissions" {
  type = string
  description = "IAM role to attach to the instance profile"
  default = "Create with read-write permissions"
}
variable "management_predefined_role" {
  type = string
  description = "(Optional) A predefined IAM role to attach to the instance profile. Ignored if IAM role is not set to 'Use existing'"
  default = ""
}
variable "gateways_blades" {
  type = bool
  description = "Turn on the Intrusion Prevention System, Application Control, Anti-Virus and Anti-Bot Blades (additional Blades can be manually turned on later)"
  default = true
}
variable "admin_cidr" {
  type = string
  description = "Allow web, ssh, and graphical clients only from this network to communicate with the Security Management Server"
}
variable "gateways_addresses" {
  type = string
  description = "Allow gateways only from this network to communicate with the Security Management Server"
}
variable "gateway_management" {
  type = string
  description = "Select 'Over the internet' if any of the gateways you wish to manage are not directly accessed via their private IP address"
  default = "Locally managed"
}

// --- Automatic Provisioning with Security Management Server Settings ---
variable "control_gateway_over_public_or_private_address" {
  type = string
  description = "Determines if the gateways are provisioned using their private or public address"
  default = "private"
}
variable "management_server" {
  type = string
  description = "(Optional) The name that represents the Security Management Server in the automatic provisioning configuration"
  default = "management-server"
}
variable "configuration_template" {
  type = string
  description = "(Optional) A name of a Security Gateway configuration template in the automatic provisioning configuration"
  default = "TGW-ASG-configuration"
  validation {
    condition     = length(var.configuration_template) < 31
    error_message = "The configuration_template name can not exceed 30 characters"
  }
}
