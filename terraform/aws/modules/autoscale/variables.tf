// --- Environment ---
variable "prefix" {
  type = string
  description = "(Optional) Instances name prefix"
  default = ""
}
variable "asg_name" {
  type = string
  description = "Autoscaling Group name"
  default = "CP-ASG-tf"
}
locals {
  asg_name = format("%s%s", var.prefix != "" ? format("%s-", var.prefix) : "", var.asg_name)
}

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs to launch resources into. Recommended at least 2"
}

// --- Automatic Provisioning with Security Management Server Settings ---
variable "gateways_provision_address_type" {
  type = string
  description = "Determines if the gateways are provisioned using their private or public address"
  default = "private"
}
locals {
  gateways_provision_address_type_allowed_values = [
    "public",
    "private"
  ]
  // Will fail if var.gateways_provision_address_type is invalid
  validate_gateways_provision_address_type = index(local.gateways_provision_address_type_allowed_values, var.gateways_provision_address_type)
}
variable "managementServer" {
  type = string
  description = "The name that represents the Security Management Server in the CME configuration"
}
variable "configurationTemplate" {
  type = string
  description = "Name of the provisioning template in the CME configuration"
}

// --- EC2 Instances Configuration ---
variable "instances_name" {
  type = string
  description = "AWS Name tag of the ASG's instances"
  default = "CP-ASG-gateway-tf"
}
variable "instance_type" {
  type = string
  description = ""
  default = "c5.xlarge"
}
module "validate_instance_type" {
  source = "../../modules/instance_type"

  chkp_type = "gateway"
  instance_type = var.instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
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
variable "version_license" {
  type = string
  description =  "Version and license of the Check Point Security Gateways"
  default = "R80.30-PAYG-NGTP-GW"
}
locals {
  version_license_allowed_values = [
    "R80.30-BYOL-GW",
    "R80.30-PAYG-NGTP-GW",
    "R80.30-PAYG-NGTX-GW",
    "R80.40-BYOL-GW",
    "R80.40-PAYG-NGTP-GW",
    "R80.40-PAYG-NGTX-GW"
  ]
  // Will fail if var.version_license is invalid
  validate_version_license = index(local.version_license_allowed_values, var.version_license)
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"
  ]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)
}
variable "password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash)"
  default = ""
}
variable "SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters)"
}
locals {
  regex_valid_sic_key = "^[a-zA-Z0-9]{8,}$"
  // Will fail if var.SICKey is invalid
  regex_sic_result = regex(local.regex_valid_sic_key, var.SICKey) == var.SICKey ? 0 : "Variable [SICKey] must be at least 8 alphanumeric characters"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable AWS Instance Connect - Ec2 Instance Connect is not supported with versions prior to R80.40"
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
variable "bootstrap_script" {
  type = string
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}

// --- Outbound Proxy Configuration (optional) ---
variable "proxy_elb_type" {
  type = string
  description = "Type of ELB to create as an HTTP/HTTPS outbound proxy"
  default = "none"
}
locals {
  proxy_elb_type_allowed_values = [
    "none",
    "internal",
    "internet-facing"
  ]
  // Will fail if var.proxy_elb_type is invalid
  validate_proxy_elb_type = index(local.proxy_elb_type_allowed_values, var.proxy_elb_type)
}
variable "proxy_elb_port" {
  type = number
  description = "The TCP port on which the proxy will be listening"
  default = 8080
}
variable "proxy_elb_clients" {
  type = string
  description = "The CIDR range of the clients of the proxy"
  default = "0.0.0.0/0"
}
locals {
  regex_valid_cidr_range = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$"
  // Will fail if var.proxy_elb_clients is invalid
  regex_cidr_result = regex(local.regex_valid_cidr_range, var.proxy_elb_clients) == var.proxy_elb_clients ? 0 : "Variable [proxy_elb_clients] must be a valid CIDR range"
}
