//********************** Basic Configuration Variables **************************//
variable "cluster_name"{
  description = "Cluster name"
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
  default     = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "sic_key" {
  description = "Secure Internal Communication(SIC) key"
  type = string
}

variable "template_name"{
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type = string
  default = "ha"
}

variable "template_version"{
  description = "Template version. It is reccomended to always use the latest template version"
  type = string
  default = "20200305"
}

variable "installation_type"{
  description = "Installaiton type"
  type = string
  default = "cluster"
}

variable "number_of_vm_instances"{
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

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
}

variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8030, check-point-cg-r8040"
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

//********************** Natworking Variables **************************//
variable "vnet_name" {
  description = "Virtual Network name"
  type = string
}

variable "address_space" {
  description = "The address space that is used by a Virtual Network."
  type = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  description = "Address prefix to be used for netwok subnets"
  type = list(string)
  default     = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "lb_probe_name" {
  description = "Name to be used for lb health probe"
  default =  "health_prob_port"
}

variable "lb_probe_port" {
  description = "Port to be used for load balancer health probes and rules"
  default     = "8117"
}

variable "lb_probe_protocol" {
  description = "Protocols to be used for load balancer health probes and rules"
  default     = "tcp"
}

variable "lb_probe_unhealthy_threshold" {
  description = "Number of times load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy."
  default     = 2
}

variable "lb_probe_interval" {
  description = "Interval in seconds load balancer health probe rule perfoms a check"
  default     = 5
}

variable "bootstrap_script"{
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