// Module: Check Point CloudGuard Network Auto Scaling Group into an existing VPC

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

// --- Environment ---
variable "prefix" {
  type = string
  description = "(Optional) Instances name prefix"
  default = ""
    validation {
    condition     = length(var.prefix) <= 40
    error_message = "Prefix can not exceed 40 characters."
  }
}
variable "asg_name" {
  type = string
  description = "Autoscaling Group name"
  default = "Check-Point-Security-Gateway-AutoScaling-Group-tf"
  validation {
    condition     = length(var.asg_name) <= 100
    error_message = "Autoscaling Group name can not exceed 100 characters."
  }
}

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
  description = "List of public subnet IDs to launch resources into. Recommended at least 2"
}

// --- Automatic Provisioning with Security Management Server Settings ---
variable "gateways_provision_address_type" {
  type = string
  description = "Determines if the gateways are provisioned using their private or public address"
  default = "private"
}

variable "allocate_public_IP" {
  type = bool
  description = "Allocate an Elastic IP for security gateway."
  default = false
}

resource "null_resource" "invalid_allocation" {
  // Will fail if var.gateways_provision_address_type is public and var.allocate_public_IP is false
  count = var.gateways_provision_address_type != "public" ? 0 : var.allocate_public_IP == true ? 0 : "Gateway's selected to be provisioned by public IP, but [allocate_public_IP] parameter is false"
}

variable "management_server" {
  type = string
  description = "The name that represents the Security Management Server in the CME configuration"
}
variable "configuration_template" {
  type = string
  description = "Name of the provisioning template in the CME configuration"
  validation {
    condition     = length(var.configuration_template) < 31
    error_message = "The configuration_template name can not exceed 30 characters."
  }
}

// --- EC2 Instances Configuration ---
variable "gateway_name" {
  type = string
  description = "The name tag of the Security Gateways instances"
  default = "Check-Point-ASG-gateway-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "c6in.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
resource "null_resource" "volume_size_too_small" {
  // Will fail if var.volume_size is less than 100
  count = var.volume_size >= 100 ? 0 : "variable volume_size must be at least 100"
}
variable "enable_volume_encryption" {
  type = bool
  description = "Encrypt Environment instances volume with default AWS KMS key"
  default = true
}
variable "instances_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added on all AutoScaling Group instances"
  default = {}
}
variable "metadata_imdsv2_required" {
  type = bool
  description = "Set true to deploy the instance with metadata v2 token required"
  default = true
}

// --- Auto Scaling Configuration ---
variable "minimum_group_size" {
  type = number
  description = "The minimum number of instances in the Auto Scaling group"
  default = 2
}
variable "maximum_group_size" {
  type = number
  description = "The maximum number of instances in the Auto Scaling group"
  default = 10
}
variable "target_groups" {
  type = list(string)
  description = "(Optional) List of Target Group ARNs to associate with the Auto Scaling group"
  default = []
}

// --- Check Point Settings ---
variable "gateway_version" {
  type = string
  description =  "Gateway version and license"
  default = "R81.20-BYOL"
}
module "validate_gateway_version" {
  source = "../modules/common/version_license"

  chkp_type = "gwlb_gw"
  version_license = var.gateway_version
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
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
  description = "The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters)"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable SSH connection over AWS web console"
  default = false
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
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}

variable "volume_type" {
  type = string
  description = "General Purpose SSD Volume Type"
  default = "gp3"
}