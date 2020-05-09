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
  description = "The location/region where rescources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

//********************** Virtual Machine Instances Variables **************************//
variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  default = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
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

variable "template_name"{
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type = string
  default = "vmss-terraform"
}

variable "template_version"{
  description = "Template version. It is reccomended to always use the latest template version"
  type = string
  default = "20200323"
}

variable "installation_type"{
  description = "Installaiton type"
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

variable "disk_size" {
  description = "Storage data disk size size(GB).Select a number between 100 and 3995"
  type = string
}

variable "os_version" {
  description = "GAIA OS version"
  type = string
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
}

variable "disable_password_authentication" {
  description = "Specifies whether password authentication should be disabled"
  type = bool
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
}

variable "configuration_template_name" {
  description = "The configuration template name as it appears in the configuration file"
  type = string
}

//********************** Natworking Variables **************************//
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

//********************* Load Balancers Variables **********************//

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
  default = "tcp"
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds load balancer health probe rule perfoms a check"
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
  description = "The name of the offer of the image that you want to deploy.Choose from: check-point-cg-r8030, check-point-cg-r8040"
  type = string
}

locals { // locals for 'vm_os_offer' allowed values
  vm_os_offer_allowed_values = [
    "check-point-cg-r8030",
    "check-point-cg-r8040"
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
  description = "Aplication ID(Client ID)"
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