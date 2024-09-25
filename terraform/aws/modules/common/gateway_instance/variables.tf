variable "external_eni_id" {
  type = string
  description = "The external-eni of the security gateway"
}
variable "internal_eni_id" {
  type = string
  description = "The internal-eni of the security gateway"
}
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Gateway-tf"
}
variable "management_server" {
  type = string
  description = "(Optional) The name that represents the Security Management Server in the automatic provisioning configuration"
  default = ""
}
variable "configuration_template" {
  type = string
  description = "(Optional) A name of a Security Gateway configuration template in the automatic provisioning configuration"
  default = ""
  validation {
    condition     = length(var.configuration_template) < 31
    error_message = "The configuration_template name can not exceed 30 characters."
  }
}
variable "control_gateway_over_public_or_private_address" {
  type = string
  description = "Determines if the Security Gateway is provisioned using its private or public address"
  default = "private"
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
  description = "KMS or CMK key Identifier: Use key ID, alias or ARN. Key alias should be prefixed with 'alias/' (e.g. for KMS default alias 'aws/ebs' - insert 'alias/aws/ebs')."
  default = "alias/aws/ebs"
}
variable "gateway_version" {
  type = string
  description =  "Gateway version & license"
  default = "R81.20-BYOL"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "c6in.xlarge"
}
module "validate_instance_type" {
  source = "../instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Gateway EC2 Instance."
  default = {}
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}
variable "ami_id" {
  type = string
  description = "The AMI to use for the instance"
}
variable "iam_instance_profile_id" {
  type = string
  description = "The IAM instance profile id"
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
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
}
variable "gateway_TokenKey" {
  type = string
  description = "Follow the instructions in SK180501 to quickly connect this Gateway to Smart-1 Cloud."
}
variable "gateway_bootstrap_script" {
  type = string
  description = "(Optional) An optional script with semicolon (;) separated commands to run on the initial boot"
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
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics"
  default = false
}
variable "primary_ntp" {
  type = string
  description = "(Optional)"
  default = ""
}
variable "secondary_ntp" {
  type = string
  description = "(Optional)"
  default = ""
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