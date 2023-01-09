//********************** Basic Configuration Variables **************************//
variable "cluster_name" {
  description = "Cluster name"
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
variable "availability_type" {
  description = "Specifies whether to deploy the solution based on Azure Availability Set or based on Azure Availability Zone."
  type = string
  default = "Availability Zone"
}

locals { // locals for 'availability_type' allowed values
  availability_type_allowed_values = [
    "Availability Zone",
    "Availability Set"
  ]
  // will fail if [var.availability_type] is invalid:
  validate_availability_type_value = index(local.availability_type_allowed_values, var.availability_type)
}

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
  description = "Administrator password of deployed Virtual Macine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "sic_key" {
  description = "Secure Internal Communication(SIC) key"
  type = string
}
resource "null_resource" "sic_key_invalid" {
  count = length(var.sic_key) >= 12 ? 0 : "SIC key must be at least 12 characters long"
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type = string
  default = "ha_terraform"
}

variable "template_version" {
  description = "Template version. It is reccomended to always use the latest template version"
  type = string
  default = "20210111"
}

variable "installation_type" {
  description = "Installaiton type"
  type = string
  default = "cluster"
}

variable "number_of_vm_instances" {
  description = "Number of VM instances to deploy "
  type = string
  default = "2"
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

locals { // locals for 'vm_os_offer' allowed values
  os_version_allowed_values = [
    "R80.40",
    "R81",
    "R81.10",
    "R81.20"
  ]
  // will fail if [var.os_version] is invalid:
  validate_os_version_value = index(local.os_version_allowed_values, var.os_version)
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
}

variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8040, check-point-cg-r81, check-point-cg-r8110, check-point-cg-r8120"
  type = string
}

locals { // locals for 'vm_os_offer' allowed values
  vm_os_offer_allowed_values = [
    "check-point-cg-r8040",
    "check-point-cg-r81",
    "check-point-cg-r8110",
    "check-point-cg-r8120"
  ]
  // will fail if [var.vm_os_offer] is invalid:
  validate_os_offer_value = index(local.vm_os_offer_allowed_values, var.vm_os_offer)
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

variable "admin_shell" {
  description = "The admin shell to configure on machine or the first time"
  type = string
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

//********************** Natworking Variables **************************//
variable "vnet_name" {
  description = "Virtual Network name"
  type = string
}

variable "address_space" {
  description = "The address space that is used by a Virtual Network."
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  description = "Address prefix to be used for netwok subnets"
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24"]
}

variable "lb_probe_name" {
  description = "Name to be used for lb health probe"
  default = "health_prob_port"
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
  default = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds load balancer health probe rule perfoms a check"
  default = 5
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  #example:
  #"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
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

variable "enable_custom_metrics" {
  description = "Indicates whether CloudGuard Metrics will be use for Cluster members monitoring."
  type = bool
  default = true
}

variable "enable_floating_ip" {
  description = "Indicates whether the load balancers will be deployed with floating IP."
  type = bool
  default = false
}

variable "use_public_ip_prefix" {
  description = "Indicates whether the public IP resources will be deployed with public IP prefix."
  type = bool
  default = false
}

variable "create_public_ip_prefix" {
  description = "Indicates whether the public IP prefix will created or an existing will be used."
  type = bool
  default = false
}

variable "existing_public_ip_prefix_id" {
  description = "The existing public IP prefix resource id."
  type = string
  default = ""
}
