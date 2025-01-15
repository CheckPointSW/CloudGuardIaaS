output "resource_group_link" {
  value = module.common.resource_group_link
}
output "public_ip" {
  value = azurerm_public_ip.public-ip.ip_address
}
output "resource_group" {
  value = azurerm_virtual_machine.mds-vm-instance.resource_group_name
}
output "vnet" {
  value = module.vnet.vnet_name
}
output "subnets" {
  value = module.vnet.vnet_subnets
}
output "location" {
  value = azurerm_virtual_machine.mds-vm-instance.location
}
output "vm_name" {
  value = azurerm_virtual_machine.mds-vm-instance.name
}
output "disk_size" {
  value = azurerm_virtual_machine.mds-vm-instance.storage_os_disk[0].disk_size_gb
}
output "os_version" {
  value = module.common.os_version
}