// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "cluster_vswitch_id" {
  type = string
  description = "The cluster vswitch of the security gateways"
}
variable "mgmt_vswitch_id" {
  type = string
  description = "The management vswitch of the security gateways"
}
variable "private_vswitch_id" {
  type = string
  description = "The private vswitch of the security gateways"
}
variable "private_route_table" {
  type = string
  description = "(Optional) Sets '0.0.0.0/0' route to the Active Cluster member instance in the specified route table (e.g. vtb-12a34567). Route table cannot have an existing 0.0.0.0/0 route. If empty - traffic will not be routed through the Security Gateway, this requires manual configuration in the Route Table"
  default=""
}

// --- ECS Instance Configuration ---
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Cluster's Security Gateway instances"
  default = "Check-Point-Cluster-tf"
}
variable "gateway_instance_type" {
  type = string
  description = "The instance type of the Security Gateways"
  default = "ecs.g5ne.xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "gateway"
  instance_type = var.gateway_instance_type
}
variable "key_name" {
  type = string
  description = "The ECS Key Pair name to allow SSH access to the instances"
}
variable "allocate_and_associate_eip" {
  type = bool
  description = "If set to TRUE, an elastic IP will be allocated and associated with each cluster member, in addition to the cluster Elastic IP"
  default = true
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
variable "disk_category" {
  type = string
  description = "(Optional) Category of the ECS disk"
  default = "cloud_efficiency"
}
variable "ram_role_name" {
  type = string
  description = "A predefined RAM role name to attach to the cluster's security gateway instances"
  default = ""
}
resource "null_resource" "volume_size_too_small" {
  // Volume Size validation - resource will not be created if the volume size is smaller than 100
  count = var.volume_size >= 100 ? 0 : "volume_size must be at least 100"
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Gateway ECS Instances"
  default = {}
}

// --- Check Point Settings ---
variable "gateway_version" {
  type = string
  description = "Gateway version and license"
  default = "R81-BYOL"
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
  description = "(Optional) Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash)"
  default = ""
}

// --- Advanced Settings ---
variable "management_ip_address" {
  type = string
  description = "(Optional) The Security Management IP address (public or private IP address). If provided, a static-route [management_ip --> via eth1] will be added to the Cluster's Security Gateway instances. If not provided, the static-route will need to be added manually post-deployment by user"
  default = ""
}
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
variable "gateway_bootstrap_script" {
  type = string
  description = "(Optional) An optional script with semicolon (;) separated commands to run on the initial boot"
  default = ""
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