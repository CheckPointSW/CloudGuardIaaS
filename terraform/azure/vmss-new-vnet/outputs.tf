output "resource_group_link" {
  value = module.common.resource_group_link
}
output "lb_public_ip" {
  value = length(azurerm_public_ip.public-ip-lb) == 1 ? azurerm_public_ip.public-ip-lb[0].ip_address : null
}
output "resource_group" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.resource_group_name
}
output "vnet" {
  value = module.vnet.vnet_name
}
output "subnets" {
  value = module.vnet.vnet_subnets
}
output "location" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.location
}
output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}
output "os_version" {
  value = module.common.os_version
}
output "disk_size" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.os_disk[0].disk_size_gb
}