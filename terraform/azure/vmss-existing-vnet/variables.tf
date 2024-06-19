//********************** Basic Configuration Variables **************************//
variable "vmss_name"{
  description = "vmss name"
  type = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "location" {
  description = "The location/region where resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

//********************** Virtual Machine Instances Variables **************************//
variable "source_image_vhd_uri" {
  type = string
  description = "The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images."
  default = "noCustomUri"
}

variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  default = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "serial_console_password_hash" {
  description = "Optional parameter, used to enable serial console connection in case of SSH key as authentication type"
  type = string
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
}

variable "availability_zones_num" {
  description = "The number of availability zones to use for Scale Set. Note that the load balancers and their IP addresses will be redundant in any case"
  #Availability Zones are only supported in several regions at this time
  #"centralus", "eastus2", "francecentral", "northeurope", "southeastasia", "westeurope", "westus2", "eastus", "uksouth"
  #type = list(string)
}

locals { // locals for 'availability_zones_num' allowed values
  availability_zones_num_allowed_values = [
    "0",
    "1",
    "2",
    "3"
  ]
  // will fail if [var.availability_zones_num] is invalid:
  validate_availability_zones_num_value = index(local.availability_zones_num_allowed_values, var.availability_zones_num)
}

variable "sic_key" {
  description = "Secure Internal Communication(SIC) key"
  type = string
}
resource "null_resource" "sic_key_invalid" {
  count = length(var.sic_key) >= 12 ? 0 : "SIC key must be at least 12 characters long"
}

variable "template_name"{
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type = string
  default = "vmss-terraform"
}

variable "template_version"{
  description = "Template version. It is recommended to always use the latest template version"
  type = string
  default = "20230910"
}

variable "installation_type"{
  description = "Installation type"
  type = string
  default = "vmss"
}

variable "number_of_vm_instances"{
  description = "Default number of VM instances to deploy"
  type = string
  default = "2"
}

variable "minimum_number_of_vm_instances" {
  description = "Minimum number of VM instances to deploy"
  type = string
}

variable "maximum_number_of_vm_instances" {
  description = "Maximum number of VM instances to deploy"
  type = string
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type = string
}


variable "os_version" {
  description = "GAIA OS version"
  type = string
}

locals { // locals for 'vm_os_offer' allowed values
  os_version_allowed_values = [
    "R8040",
    "R81",
    "R8110",
    "R8120"
  ]
  // will fail if [var.os_version] is invalid:
  validate_os_version_value = index(local.os_version_allowed_values, var.os_version)
}
variable "disk_size" {
  description = "Storage data disk size size(GB). Select a number between 100 and 3995, if you are using R81.20 or below, the disk size must be 100"
  type = string
  default = 100
}
resource "null_resource" "disk_size_validation" {
  // Will fail if var.disk_size is not 100 and the version is R81.20 or below
  count = tonumber(var.disk_size) != 100 && contains(["R8040", "R81", "R8110", "R8120"], var.os_version) ? "variable disk_size can not be changed for R81.20 and below" : 0
}
variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type = string
}
locals { // locals for 'authentication_type' allowed values
  authentication_type_allowed_values = [
    "Password",
    "SSH Public Key"
  ]
  // will fail if [var.authentication_type] is invalid:
  validate_authentication_type_value = index(local.authentication_type_allowed_values, var.authentication_type)
}

variable "allow_upload_download" {
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  type = bool
}

variable "is_blink" {
  description = "Define if blink image is used for deployment"
  default = true
}

variable "management_name" {
  description = "The name of the management server as it appears in the configuration file"
  type = string
}

variable "management_IP" {
  description = "The IP address used to manage the VMSS instances"
  type = string
}

variable "management_interface" {
  description = "Manage the Gateways in the Scale Set via the instance's external (eth0) or internal (eth1) NIC's private IP address"
  type = string
  default = "eth1-private"
}
locals { // locals for 'management_interface' allowed values
  management_interface_allowed_values = [
    "eth0-public",
    "eth0-private",
    "eth1-private"
  ]
  // will fail if [var.management_interface] is invalid:
  validate_management_interface_value = index(local.management_interface_allowed_values, var.management_interface)
}

variable "configuration_template_name" {
  description = "The configuration template name as it appears in the configuration file"
  type = string
}

variable "admin_shell" {
  description = "The admin shell to configure on machine or the first time"
  type = string
  default = "/etc/cli.sh"
}

locals {
  admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"
  ]
  // Will fail if [var.admin_shell] is invalid
  validate_admin_shell_value = index(local.admin_shell_allowed_values, var.admin_shell)
}

//********************** Networking Variables **************************//
variable "vnet_name" {
  description = "Virtual Network name"
  type = string
}

variable "frontend_subnet_name" {
  description = "Frontend subnet name"
  type = string
}

variable "backend_subnet_name" {
  description = "Backend subnet name"
  type = string
}

variable "vnet_resource_group" {
  description = "Resource group of existing vnet"
  type = string
}

variable "vnet_allocation_method" {
  description = "IP address allocation method"
  type = string
  default = "Static"
}

variable "add_storage_account_ip_rules" {
  type = bool
  default = false
  description = "Add Storage Account IP rules that allow access to the Serial Console only for IPs based on their geographic location"
}

variable "storage_account_additional_ips" {
  type = list(string)
  description = "IPs/CIDRs that are allowed access to the Storage Account"
  default = []
}//********************* Load Balancers Variables **********************//
variable "deployment_mode" {
  description = "The type of the deployment, can be 'Standard' for both load balancers or 'External' for external load balancer or 'Internal for internal load balancer"
  type = string
  default = "Standard"
}

locals {  // locals for 'deployment_mode' allowed values
  deployment_mode_allowd_values = [
    "Standard",
    "External",
    "Internal"
  ]
  // will fail if [var.deployment_mode] is invalid:
  validate_deployment_mode_value = index(local.deployment_mode_allowd_values, var.deployment_mode)
}

variable "backend_lb_IP_address" {
  description = "The IP address is defined by its position in the subnet"
  type = number
}

variable "lb_probe_port" {
  description = "Port to be used for load balancer health probes and rules"
  default = "8117"
}

variable "lb_probe_protocol" {
  description = "Protocols to be used for load balancer health probes and rules"
  default = "Tcp"
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds load balancer health probe rule performs a check"
  default = 5
}

variable "frontend_port" {
  description = "Port that will be exposed to the external Load Balancer"
  type = string
  default = "80"
}

variable "backend_port" {
  description = "Port that will be exposed to the external Load Balance"
  type = string
  default = "8081"
}

variable "frontend_load_distribution" {
  description = "Specifies the load balancing distribution type to be used by the frontend load balancer"
  type = string
}

locals { // locals for 'frontend_load_distribution' allowed values
  frontend_load_distribution_allowed_values = [
    "Default",
    "SourceIP",
    "SourceIPProtocol"
  ]
  // will fail if [var.frontend_load_distribution] is invalid:
  validate_frontend_load_distribution_value = index(local.frontend_load_distribution_allowed_values, var.frontend_load_distribution)
}

variable "backend_load_distribution" {
  description = "Specifies the load balancing distribution type to be used by the backend load balancer"
  type = string
}

locals { // locals for 'frontend_load_distribution' allowed values
  backend_load_distribution_allowed_values = [
    "Default",
    "SourceIP",
    "SourceIPProtocol"
  ]
  // will fail if [var.backend_load_distribution] is invalid:
  validate_backend_load_distribution_value = index(local.backend_load_distribution_allowed_values, var.backend_load_distribution)
}

//********************** Scale Set variables *******************//

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy.Choose from: check-point-cg-r8040, check-point-cg-r81, check-point-cg-r8110, check-point-cg-r8120"
  type = string
}

locals { // locals for 'vm_os_offer' allowed values
  vm_os_offer_allowed_values = [
    "check-point-cg-r8040",
    "check-point-cg-r81",
    "check-point-cg-r8110",
    "check-point-cg-r8120",
  ]
  // will fail if [var.vm_os_offer] is invalid:
  validate_os_offer_value = index(local.vm_os_offer_allowed_values, var.vm_os_offer)
}

variable "bootstrap_script"{
  description = "An optional script to run on the initial boot"
  #example:
  #"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
}

variable "notification_email" {
  description = "Specifies a list of custom email addresses to which the email notifications will be sent"
  type = string
}

//********************** Credentials **************************//
variable "tenant_id" {
  description = "Tenant ID"
  type = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type = string
}

variable "client_id" {
  description = "Application ID(Client ID)"
  type = string
}

variable "client_secret" {
  description = "A secret string that the application uses to prove its identity when requesting a token. Also can be referred to as application password."
  type = string
}

variable "sku" {
  description = "SKU"
  type = string
  default = "Standard"
}

variable "enable_custom_metrics" {
  description = "Enable CloudGuard metrics in order to send statuses and statistics collected from VMSS instances to the Azure Monitor service."
  type = bool
  default = true
}

variable "enable_floating_ip" {
  description = "Indicates whether the load balancers will be deployed with floating IP."
  type = bool
  default = false
}

variable "nsg_id" {
  description = "NSG ID - Optional - if empty use default NSG"
  default = ""
}
