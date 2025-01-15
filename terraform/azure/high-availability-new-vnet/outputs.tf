locals {
  vms = local.availability_set_condition? azurerm_virtual_machine.vm-instance-availability-set : azurerm_virtual_machine.vm-instance-availability-zone
}
output "resource_group_link" {
  value = module.common.resource_group_link
}
output "public_ips" {
  value = azurerm_public_ip.public-ip[*].ip_address
}
output "resource_group" {
  value = local.vms[0].resource_group_name
}
output "vnet" {
  value = module.vnet.vnet_name
}
output "subnets" {
  value = module.vnet.vnet_subnets
}
output "locations" {
  value = local.vms[*].location
}
output "vm_names" {
  value = local.vms[*].name
}
output "disk_size" {
  value = local.vms[0].storage_os_disk[0].disk_size_gb
}
output "os_version" {
  value = module.common.os_version
}