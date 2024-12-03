// Module: Check Point CloudGuard Network Security Gateway & Management (Standalone) instance into an existing VPC

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

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "public_subnet_id" {
  type = string
  description = "The public subnet of the Security Gateway & Management (Standalone)"
}
variable "private_subnet_id" {
  type = string
  description = "The private subnet of the Security Gateway & Management (Standalone)"
}
variable "private_route_table" {
  type = string
  description = "Sets '0.0.0.0/0' route to the Security Gateway & Management (Standalone) instance in the specified route table (e.g. rtb-12a34567)"
  default= ""
}

// --- EC2 Instance Configuration ---
variable "standalone_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway & Management (Standalone) instance"
  default = "Check-Point-Standalone-tf"
}
variable "standalone_instance_type" {
  type = string
  description = "The instance type of the Security Gateway & Management (Standalone) instance"
  default = "c5.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "standalone"
  instance_type = var.standalone_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}
variable "allocate_and_associate_eip" {
  type = bool
  description = "If set to true, an elastic IP will be allocated and associated with the launched instance"
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
variable "metadata_imdsv2_required" {
  type = bool
  description = "Set true to deploy the instance with metadata v2 token required"
  default = true
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Standalone EC2 Instance"
  default = {}
}

// --- Check Point Settings ---
variable "standalone_version" {
  type = string
  description =  "Security Gateway & Management (Standalone) version and license"
  default = "R81.20-BYOL"
}
module "validate_standalone_version" {
  source = "../modules/common/version_license"

  chkp_type = "standalone"
  version_license = var.standalone_version
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "standalone_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}
variable "standalone_maintenance_mode_password_hash" {
  description = "(optional) Check Point recommends setting Admin user's password and maintenance-mode password for recovery purposes. For R81.10 and below the Admin user's password is used also as maintenance-mode password. (To generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here)."
  type = string
  default = ""
}

// --- Advanced Settings ---
variable "resources_tag_name" {
  type = string
  description = "(Optional) The name tag of the resources"
  default = ""
}
variable "standalone_hostname" {
  type = string
  description = "(Optional) Security Gateway & Management (Standalone) prompt hostname"
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
variable "standalone_bootstrap_script" {
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
variable "admin_cidr" {
  type = string
  description = "(CIDR) Allow web, ssh, and graphical clients only from this network to communicate with the Management Server"
  default = "0.0.0.0/0"
}
variable "gateway_addresses" {
  type = string
  description = "(CIDR) Allow gateways only from this network to communicate with the Management Server"
  default = "0.0.0.0/0"
}
