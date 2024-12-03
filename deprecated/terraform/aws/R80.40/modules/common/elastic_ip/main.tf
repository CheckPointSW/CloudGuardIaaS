resource "aws_eip" "gateway_eip" {
  count = local.allocate_and_associate_eip_condition
  network_interface = var.external_eni_id
}
resource "aws_eip_association" "address_assoc" {
  count = local.allocate_and_associate_eip_condition
  allocation_id = aws_eip.gateway_eip[count.index].id
  network_interface_id = var.external_eni_id
  private_ip_address = var.private_ip_address
}