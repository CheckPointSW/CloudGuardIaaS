resource "alicloud_eip" "instance_eip" {
  count = local.allocate_and_associate_eip_condition
  address_name  = var.eip_name
}
resource "alicloud_eip_association" "address_assoc" {
  count = local.allocate_and_associate_eip_condition
  allocation_id = alicloud_eip.instance_eip[count.index].id
  instance_id = var.instance_id
  instance_type = var.association_instance_type
}