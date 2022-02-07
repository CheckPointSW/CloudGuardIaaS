output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "resource_group_id" {
  value = azurerm_resource_group.resource_group.id
}

output "resource_group_location" {
  value = azurerm_resource_group.resource_group.location
}

output "azurerm_resource_group_id" {
  value = azurerm_resource_group.resource_group.id
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password"{
  value = var.admin_password
}

output "vm_instance_identity" {
  value = var.vm_instance_identity_type
}

output "template_name"{
  value = var.template_name
}

output "template_version" {
  value = var.template_version
}

output "bootstrap_script"{
  value = var.bootstrap_script
}

output "os_version" {
  value = var.os_version
}

output "installation_type" {
  value = var.installation_type
}

output "number_of_vm_instances" {
  value = var.number_of_vm_instances
}

output "allow_upload_download" {
  value = var.allow_upload_download
}

output "is_blink" {
  value = var.is_blink
}

output "vm_size" {
  value = var.vm_size
}

output "delete_os_disk_on_termination" {
  value = var.delete_os_disk_on_termination
}

output "vm_os_offer" {
  value = var.vm_os_offer
}

output "vm_os_sku" {
  value = var.vm_os_sku
}

output "vm_os_version" {
  value = var.vm_os_version
}

output "storage_account_type" {
  value = var.storage_account_type
}

output "storage_account_tier" {
  value = var.storage_account_tier
}

output "account_replication_type" {
  value = var.account_replication_type
}

output "disk_size" {
  value = var.disk_size
}

output "publisher" {
  value = var.publisher
}

output "storage_os_disk_create_option" {
  value = var.storage_os_disk_create_option
}

output "storage_os_disk_caching" {
  value = var.storage_os_disk_caching
}

output "managed_disk_type" {
  value = var.managed_disk_type
}

output "authentication_type" {
  value = var.authentication_type
}

output "tags" {
  value = var.tags
}

output "boot_diagnostics" {
  value = var.boot_diagnostics
}

output "role_definition" {
  value = var.role_definition
}