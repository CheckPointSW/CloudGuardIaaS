// Module: Check Point CloudGuard Network Gateway Load Balancer into an existing VPC

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
variable "vpc_id" {
  type = string
}
variable "internet_gateway_id" {
  type = string
  description = "VPC's Internet Gateway Id (e.g. igw-123a4567)"
}
variable "availability_zones"{
  type = list(string)
  description = "The Availability Zones (AZs) to use for the subnets in the VPC. Select two (the logical order is preserved)"
}
variable "number_of_AZs" {
  type = number
  description = "Number of Availability Zones to use in the VPC. This must match your selections in the list of Availability Zones parameter"
  default = 2
}
resource "null_resource" "availability_zones_validation1" {
  count = var.number_of_AZs == length(var.availability_zones) ? 0 : "variable availability_zones list size must be equal to variable num_of_AZs"
}

variable "gateways_subnets" {
  type = list(string)
  description = "Select at least 2 public subnets in the VPC. If you choose to deploy a Security Management Server it will be deployed in the first subnet"
}

variable "transit_gateway_attachment_subnet_1_id" {
  type = string
  description = "The TGW attachment subnet ID located in the 1st Availability Zone"
}
variable "transit_gateway_attachment_subnet_2_id" {
  type = string
  description = "The TGW attachment subnet ID located in the 2st Availability Zone"
}
variable "transit_gateway_attachment_subnet_3_id" {
  type = string
  description = "The TGW attachment subnet ID located in the 3st Availability Zone"
  default = ""
}
variable "transit_gateway_attachment_subnet_4_id" {
  type = string
  description = "The TGW attachment subnet ID located in the 4st Availability Zone"
  default = ""
}
variable "nat_gw_subnet_1_cidr" {
  type = string
  description = "CIDR block for NAT subnet 1 located in the 1st Availability Zone"
  default = "10.0.13.0/24"
}
variable "nat_gw_subnet_2_cidr" {
  type = string
  description = "CIDR block for NAT subnet 2 located in the 2st Availability Zone"
  default = "10.0.23.0/24"
}
variable "nat_gw_subnet_3_cidr" {
  type = string
  description = "CIDR block for NAT subnet 3 located in the 3st Availability Zone"
  default = "10.0.33.0/24"
}
variable "nat_gw_subnet_4_cidr" {
  type = string
  description = "CIDR block for NAT subnet 4 located in the 4st Availability Zone"
  default = "10.0.43.0/24"
}
variable "gwlbe_subnet_1_cidr" {
  type = string
  description = "CIDR block for Gateway Loadbalancer endpoint subnet 1 located in the 1st Availability Zone"
  default = "10.0.14.0/24"
}
variable "gwlbe_subnet_2_cidr" {
  type = string
  description = "CIDR block for Gateway Loadbalancer endpoint subnet 2 located in the 2st Availability Zone"
  default = "10.0.24.0/24"
}
variable "gwlbe_subnet_3_cidr" {
  type = string
  description = "CIDR block for Gateway Loadbalancer endpoint subnet 3 located in the 3st Availability Zone"
  default = "10.0.34.0/24"
}
variable "gwlbe_subnet_4_cidr" {
  type = string
  description = "CIDR block for Gateway Loadbalancer endpoint subnet 4 located in the 4st Availability Zone"
  default = "10.0.44.0/24"
}
// --- General Settings ---
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
}
variable "enable_volume_encryption" {
  type = bool
  description = "Encrypt Environment instances volume with default AWS KMS key"
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
variable "volume_type" {
  type = string
  description = "General Purpose SSD Volume Type"
  default = "gp3"
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
variable "management_server" {
  type = string
  description = "The name that represents the Security Management Server in the automatic provisioning configuration."
  default = "gwlb-management-server"
}
variable "configuration_template" {
  type = string
  description = "A name of a gateway configuration template in the automatic provisioning configuration."
  default = "gwlb-ASG-configuration"
  validation {
    condition     = length(var.configuration_template) < 31
    error_message = "The configuration_template name can not exceed 30 characters"
  }
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}

// --- Gateway Load Balancer Configuration ---

variable "gateway_load_balancer_name" {
  type = string
  description =  "Gateway Load Balancer name. This name must be unique within your AWS account and can have a maximum of 32 alphanumeric characters and hyphens. A name cannot begin or end with a hyphen."
  default = "gwlb1"
}
resource "null_resource" "gateway_load_balancer_name_too_long" {
  // Will fail if gateway_load_balancer_name more than 32
  count = length(var.gateway_load_balancer_name) <= 32 ? 0 : "variable gateway_load_balancer_name must be at most 32"
}
variable "target_group_name" {
  type = string
  description =  "Target Group Name. This name must be unique within your AWS account and can have a maximum of 32 alphanumeric characters and hyphens. A name cannot begin or end with a hyphen."
  default = "tg1"
}
resource "null_resource" "target_group_name_too_long" {
  // Will fail if target_group_name more than 32
  count = length(var.target_group_name) <= 32 ? 0 : "variable target_group_name must be at most 32"
}
variable "enable_cross_zone_load_balancing" {
  type = bool
  description =  "Select 'true' to enable cross-az load balancing. NOTE! this may cause a spike in cross-az charges."
  default = true
}

// --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---

variable "gateway_name" {
  type = string
  description = "The name tag of the Security Gateway instances. (optional)"
  default = "Check-Point-Gateway-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The EC2 instance type for the Security Gateways."
  default = "c6in.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "minimum_group_size" {
  type = number
  description = "The minimal number of Security Gateways."
  default = 2
}
variable "maximum_group_size" {
  type = number
  description = "The maximal number of Security Gateways."
  default = 10
}
variable "gateway_version" {
  type = string
  description =  "The version and license to install on the Security Gateways."
  default = "R81.20-BYOL"
}
module "validate_gateway_version" {
  source = "../modules/common/version_license"

  chkp_type = "gwlb_gw"
  version_license = var.gateway_version
}
variable "gateway_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
}
variable "gateway_maintenance_mode_password_hash" {
  description = "Maintenance mode password hash for the gateway instances, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}
variable "gateway_SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters)"
}

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

variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics."
  default = false
}

variable "gateway_bootstrap_script" {
  type = string
  description = "(Optional) An optional script with semicolon (;) separated commands to run on the initial boot"
  default = ""
}

// --- Check Point CloudGuard IaaS Security Management Server Configuration ---

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
  description = "Maintenance mode password hash for the management instance, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}
variable "gateways_policy" {
  type = string
  description = "The name of the Security Policy package to be installed on the gateways in the Security Gateways Auto Scaling group"
  default = "Standard"
}
variable "gateway_management" {
  type = string
  description = "Select 'Over the internet' if any of the gateways you wish to manage are not directly accessed via their private IP address."
  default = "Locally managed"
}
variable "admin_cidr" {
  type = string
  description = "Allow web, ssh, and graphical clients only from this network to communicate with the Security Management Server"
}
variable "gateways_addresses" {
  type = string
  description = "Allow gateways only from this network to communicate with the Security Management Server"
}

