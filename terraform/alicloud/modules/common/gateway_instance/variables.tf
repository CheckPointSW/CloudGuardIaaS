variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Gateway-tf"
}
variable "vswitch_id" {
  type = string
  description = "The public vswitch of the security gateway"
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
variable "disk_category" {
  type = string
  description = "(Optional) Category of the ECS disk"
  default = "cloud_efficiency"
}
variable "gateway_version" {
  type = string
  description =  "Gateway version and license"
  default = "R81-BYOL"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateway"
  default = "ecs.c5.xlarge"
}
module "validate_instance_type" {
  source = "../instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Gateway ECS Instance"
  default = {}
}
variable "key_name" {
  type = string
  description = "The ECS Key Pair name to allow SSH access to the instance"
}
variable "image_id" {
  type = string
  description = "The image ID to use for the instance"
}
variable "security_groups" {
  type = list(string)
  description = "The security groups of the instance"
}
variable "gateway_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash)"
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