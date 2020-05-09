//************** Basic config variables**************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "resource_group_id" {
  description = "Azure Resource Group ID to use."
  type = string
  default = ""
}

variable "location" {
  description = "The location/region where rescources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}
//************** Virtual machine instance variables **************
variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  type = string
  default     = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = {}
}

variable "boot_diagnostics" {
  type        = bool
  description = "Enable or Disable boot diagnostics"
  default     = true
}

variable "vm_instance_identity_type" {
  description = "Managed Service Identity type"
  type = string
  default = "SystemAssigned"
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
}

variable "template_version"{
  description = "Template name. Should be defined according to deployment type(e.g. ha, vmss)"
  type = string
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  type = string
  default = ""
}

variable "os_version"{
  description = "GAIA OS version"
  type = string
}

locals { // locals for 'os_version' allowed values
  os_version_allowed_values = [
    "R80.30",
    "R80.40"
  ]
  // will fail if [var.installation_type] is invalid:
  validate_os_version_value = index(local.os_version_allowed_values, var.os_version)
}

variable "installation_type"{
  description = "Installaiton type. Allowed values: cluster, vmss"
  type = string
}

locals { // locals for 'installation_type' allowed values
  installation_type_allowed_values = [
    "cluster",
    "vmss"
  ]
  // will fail if [var.installation_type] is invalid:
  validate_installation_type_value = index(local.installation_type_allowed_values, var.installation_type)
}

variable "number_of_vm_instances"{
  description = "Number of VM instances to deploy"
  type = string
}

variable "allow_upload_download" {
  description = "Allow upload/download to Check Point"
  type = bool
}

variable "is_blink" {
  description = "Define if blink image is used for deployment"
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type = string
}

locals {// locals for  'vm_size' allowed values
  allowed_vm_sizes = ["Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_F2s",
    "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_D4s_v3", "Standard_D8s_v3",
    "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D64s_v3", "Standard_E4s_v3", "Standard_E8s_v3",
    "Standard_E16s_v3", "Standard_E20s_v3", "Standard_E32s_v3", "Standard_E64s_v3", "Standard_E64is_v3",
    "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F64s_v2",
    "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s",
    "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2", "Standard_D11_v2",
    "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2", "Standard_F2",
    "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3",
    "Standard_D32_v3", "Standard_D64_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3",
    "Standard_E20_v3", "Standard_E32_v3", "Standard_E64_v3", "Standard_E64i_v3", "Standard_DS11_v2",
    "Standard_DS12_v2", "Standard_DS13_v2", "Standard_DS14_v2", "Standard_DS15_v2"
  ]
  // will fail if [var.vm_size] is invalid:
  validate_vm_size_value = index(local.allowed_vm_sizes, var.vm_size)
}
variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when VM is terminated"
  default     = true
}

variable "publisher" {
  description = "CheckPoint publicher"
  default = "checkpoint"
}

//************** Storage image reference and plan variables ****************//
variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8030, check-point-cg-r8040"
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

variable "vm_os_sku" {
  /*
    Choose from:
      - "sg-byol"
      - "sg-ngtp-v2" (for R80.30 only)
      - "sg-ngtx-v2" (for R80.30 only)
      - "sg-ngtp" (for R80.40 only)
      - "sg-ngtx" (for R80.40 only)
  */
  description = "The sku of the image to be deployed"
  type = string
}

locals { // locals for 'vm_os_sku' allowed values
  vm_os_sku_allowed_values = [
    "sg-byol",
    "sg-ngtp",
    "sg-ngtx",
    "sg-ngtp-v2",
    "sg-ngtx-v2"
  ]
  // will fail if [var.vm_os_sku] is invalid:
  validate_vm_os_sku_value = index(local.vm_os_sku_allowed_values, var.vm_os_sku)
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. "
  type = string
  default = "latest"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options is Standard_LRS, Premium_LRS"
  type = string
  default     = "Standard_LRS"
}

locals { // locals for 'storage_account_type' allowed values
  storage_account_type_allowed_values = [
    "Standard_LRS",
    "Premium_LRS"
  ]
  // will fail if [var.storage_account_type] is invalid:
  validate_storage_account_type_value = index(local.storage_account_type_allowed_values, var.storage_account_type)
}

variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account.Valid options are Standard and Premium"
  default = "Standard"
}

locals { // locals for 'storage_account_tier' allowed values
  storage_account_tier_allowed_values = [
   "Standard",
   "Premium"
  ]
  // will fail if [var.storage_account_tier] is invalid:
  validate_storage_account_tier_value = index(local.storage_account_tier_allowed_values, var.storage_account_tier)
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account.Valid options are LRS, GRS, RAGRS and ZRS"
  type = string
  default = "LRS"
}

locals { // locals for 'account_replication_type' allowed values
  account_replication_type_allowed_values = [
   "LRS",
   "GRS",
   "RAGRS",
   "ZRS"
  ]
  // will fail if [var.account_replication_type] is invalid:
  validate_account_replication_type_value = index(local.account_replication_type_allowed_values, var.account_replication_type)
}

variable "disk_size" {
  description = "Storage data disk size size(GB).Select a number between 100 and 3995"
  type = string
}

locals { // local for 'disk_size' allowed regex
  regex_disk_size_range = "^([1-9][0-9][0-9]|[1-2][0-9][0-9][0-9]|3[0-8][0-9][0-9]|399[0-5])$"
  // Will fail if var.disk_size is invalid
  regex_disk_size_result = regex(local.regex_disk_size_range, var.disk_size) == var.disk_size ? 0 : "Variable [disk_size] must be a between 100 and 3995"
}

//************** Storage OS disk variables **************//
variable "storage_os_disk_create_option" {
  description = "The method to use when creating the managed disk"
  type = string
  default = "FromImage"
}

variable "storage_os_disk_caching" {
  description = "Specifies the caching requirements for the OS Disk"
  default = "ReadWrite"
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS"
  type = string
  default     = "Standard_LRS"
}

locals { // locals for 'managed_disk_type' allowed values
  managed_disk_type_allowed_values = [
   "Standard_LRS",
   "Premium_LRS"
  ]
  // will fail if [var.managed_disk_type] is invalid:
  validate_managed_disk_type_value = index(local.managed_disk_type_allowed_values, var.managed_disk_type)
}

variable "disable_password_authentication" {
  description = "Disable password authentication"
  type = bool
  default = false
}

//********************** Role Assigments variables**************************//
variable "role_definition" {
  description = "Role definition. The full list of Azure Built-in role descriptions can be found at https://docs.microsoft.com/bs-latn-ba/azure/role-based-access-control/built-in-roles"
  type = string
  default = "Contributor"
}