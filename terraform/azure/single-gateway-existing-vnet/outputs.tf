output "resource_group_link" {
  value = module.common.resource_group_link
}
output "public_ip" {
  value = azurerm_public_ip.public-ip.ip_address
}
output "resource_group" {
  value = azurerm_virtual_machine.single-gateway-vm-instance.resource_group_name
}
output "subnets" {
  value = [data.azurerm_subnet.backend_subnet.id, data.azurerm_subnet.frontend_subnet.id]
}
output "location" {
  value = azurerm_virtual_machine.single-gateway-vm-instance.location
}
output "vm_name" {
  value = azurerm_virtual_machine.single-gateway-vm-instance.name
}
output "disk_size" {
  value = azurerm_virtual_machine.single-gateway-vm-instance.storage_os_disk[0].disk_size_gb
}
output "os_version" {
  value = module.common.os_version
}