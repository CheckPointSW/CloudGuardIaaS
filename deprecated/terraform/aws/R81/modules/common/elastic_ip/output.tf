output "gateway_eip_id" {
  value = aws_eip.gateway_eip.*.id
}
output "gateway_eip_public_ip" {
  value = aws_eip.gateway_eip.*.public_ip
}
output "gateway_eip_attached_instance" {
  value = aws_eip.gateway_eip.*.instance
}
