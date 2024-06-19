// Module: Check Point CloudGuard Network Security Management Server into an existing VPC

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
variable "subnet_id" {
  type = string
  description = "To access the instance from the internet, make sure the subnet has a route to the internet"
}

// --- EC2 Instance Configuration ---
variable "management_name" {
  type = string
  description = "(Optional) The name tag of the Security Management instance"
  default = "Check-Point-Management-tf"
}
variable "management_instance_type" {
  type = string
  description = "The instance type of the Security Management Server"
  default = "m5.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "management"
  instance_type = var.management_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
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
  // Will fail if var.volume_size is less than 100
  count = var.volume_size >= 100 ? 0 : "variable volume_size must be at least 100"
}
variable "volume_encryption" {
  type = string
  description = "KMS or CMK key Identifier: Use key ID, alias or ARN. Key alias should be prefixed with 'alias/' (e.g. for KMS default alias 'aws/ebs' - insert 'alias/aws/ebs')"
  default = "alias/aws/ebs"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable AWS Instance Connect - Ec2 Instance Connect is not supported with versions prior to R80.40"
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
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Management EC2 Instance"
  default = {}
}

// --- IAM Permissions (ignored when the installation is not Primary Management Server) ---
variable "iam_permissions" {
  type = string
  description = "IAM role to attach to the instance profile"
  default = "Create with read permissions"
}
variable "predefined_role" {
  type = string
  description = "(Optional) A predefined IAM role to attach to the instance profile. Ignored if var.iam_permissions is not set to 'Use existing'"
  default = ""
}
variable "sts_roles" {
  type = list(string)
  description = "(Optional) The IAM role will be able to assume these STS Roles (list of ARNs). Ignored if var.iam_permissions is set to 'None' or 'Use existing'"
  default = []
}

// --- Check Point Settings ---
variable "management_version" {
  type = string
  description = "Management version and license"
  default = "R81.20-BYOL"
}
module "validate_management_version" {
  source = "../modules/common/version_license"

  chkp_type = "management"
  version_license = var.management_version
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
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

// --- Security Management Server Settings ---
variable "management_hostname" {
  type = string
  description = "(Optional) Security Management Server prompt hostname"
  default = ""
}
variable "management_installation_type" {
  type = string
  description = "Determines the Management Server installation type: Primary management, Secondary management, Log Server"
  default = "Primary management"
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
  description = "(CIDR) Allow web, ssh, and graphical clients only from this network to communicate with the Security Management Server"
  default = "0.0.0.0/0"
}
variable "gateway_addresses" {
  type = string
  description = "(CIDR) Allow gateways only from this network to communicate with the Security Management Server"
  default = "0.0.0.0/0"
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
variable "management_bootstrap_script" {
  type = string
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}
variable "volume_type" {
  type = string
  description = "General Purpose SSD Volume Type"
  default = "gp3"
}
variable "is_gwlb_iam" {
  type = bool
  default = false
}