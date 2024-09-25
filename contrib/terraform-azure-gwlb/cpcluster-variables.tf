//********************** Basic Configuration Variables **************************//
variable "cluster_name" {
  description = "Cluster name"
  type = string
  default = "cpcluster"
}

variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
  default = "rg-cpcluster"
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
  default = "cpadmin"
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
  default = "Standard_D2_v2"
}

variable "disk_size" {
  description = "Storage data disk size size(GB).Select a number between 100 and 3995"
  type = string
  default = "110"
}

variable "os_version" {
  description = "GAIA OS version"
  type = string
  default = "R80.40"
}

variable "vm_os_sku" {
  description = "The sku of the image to be deployed."
  type = string
  default = "sg-byol"
}

variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8030, check-point-cg-r8040, check-point-cg-r81"
  type = string
  default = "check-point-cg-r8040"
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type = string
  default = "Password"
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
  default = true
}

variable "is_blink" {
  description = "Define if blink image is used for deployment"
  default = true
}

//********************** Natworking Variables **************************//
variable "frontend_IP_addresses" {
  description = "A list of three whole numbers representing the private ip addresses of the members eth0 NICs and the cluster vip ip addresses. The numbers can be represented as binary integers with no more than the number of digits remaining in the address after the given frontend subnet prefix. The IP addresses are defined by their position in the frontend subnet."
  type = list(number)
  default = [5, 6, 7]
}

variable "backend_IP_addresses" {
  description = "A list of three whole numbers representing the private ip addresses of the members eth1 NICs and the backend lb ip addresses. The numbers can be represented as binary integers with no more than the number of digits remaining in the address after the given backend subnet prefix. The IP addresses are defined by their position in the backend subnet."
  type = list(number)
  default = [5, 6, 7]
}

variable "vnet_allocation_method" {
  description = "IP address allocation method"
  type = string
  default = "Static"
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
  default = ""
  #example:
  #"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
}

//********************** Credentials **************************//
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

variable "cpcluster-sku-enabled" {
    description = "Have you ever deployed a ckp cluster before? set to false if not"
    type = bool
    default = true
}