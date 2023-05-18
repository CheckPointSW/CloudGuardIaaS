// Module: Check Point CloudGuard Network Quick Start Auto Scaling
//Deploy a Check Point CloudGuard Network Security Gateways Auto Scaling Group, an external ALB/NLB, and optionally a Security Management Server and a web server Auto Scaling Group in a new VPC.

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
}
variable "asg_name" {
  type = string
  description = "Autoscaling Group name"
  default = "Check-Point-ASG-tf"
}
// --- Network Configuration ---
variable "vpc_cidr" {
  type = string
  description = "The CIDR block of the VPC"
  default = "10.0.0.0/16"
}
variable "public_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 1} ) "
}
variable "private_subnets_map" {
  type = map(string)
  description = "A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 2 pairs.  (e.g. {\"us-east-1a\" = 2} ) "

}
variable "subnets_bit_length" {
  type = number
  description = "Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a subnets_bit_length value of 4, the resulting subnet address will have length /20"
}

// --- General Settings ---
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
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
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "provision_tag" {
  type = string
  description = "The tag is used by the Security Management Server to automatically provision the Security Gateways. Must be up to 12 alphanumeric characters and unique for each Quick Start deployment"
  default = "quickstart"
}
variable "load_balancers_type" {
  type = string
  description = "Use Network Load Balancer if you wish to preserve the source IP address and Application Load Balancer if you wish to use content based routing"
  default = "Network Load Balancer"
}
variable "load_balancer_protocol" {
  type = string
  description = "The protocol to use on the Load Balancer"
}
variable "certificate" {
  type = string
  description = "Amazon Resource Name (ARN) of an HTTPS Certificate, ignored if the selected protocol is HTTP"
}
variable "service_port" {
  type = string
  description = "The external Load Balancer listens to this port. Leave this field blank to use default ports: 80 for HTTP and 443 for HTTPS"
}

// --- Check Point CloudGuard Network Security Gateways Auto Scaling Group Configuration ---
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "c5.xlarge"
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
  default = "R81.10-BYOL"
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
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
}
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics"
  default = false
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
  default = "R81.10-BYOL"
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
variable "gateways_policy" {
  type = string
  description = "The name of the Security Policy package to be installed on the gateways in the Security Gateways Auto Scaling group"
  default = "Standard"
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

// --- Web Servers Auto Scaling Group Configuration ---
variable "servers_deploy" {
  type = bool
  description = "Select 'true' to deploy web servers and an internal Application Load Balancer. If you select 'false' the other parameters of this section will be ignored"
  default = false
}
variable "servers_instance_type" {
  type = string
  description = "The EC2 instance type for the web servers"
  default = "t3.micro"
}
module "validate_servers_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "server"
  instance_type = var.servers_instance_type
}
variable "server_ami" {
  type = string
  description = "The Amazon Machine Image ID of a preconfigured web server (e.g. ami-0dc7dc63)"
}
