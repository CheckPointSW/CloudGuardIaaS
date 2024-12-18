output "ami_id" {
  value = module.amis.ami_id
}
output "cluster_public_ip" {
  value = aws_eip.cluster_eip.*.public_ip
}
output "member_a_public_ip" {
  value = aws_eip.member_a_eip.*.public_ip
}
output "member_b_public_ip" {
  value = aws_eip.member_b_eip.*.public_ip
}
output "member_a_ssh" {
  value = var.allocate_and_associate_eip ? format("ssh -i %s admin@%s", var.key_name, aws_eip.member_a_eip[0].public_ip) : ""
}
output "member_b_ssh" {
  value = var.allocate_and_associate_eip ? format("ssh -i %s admin@%s", var.key_name, aws_eip.member_b_eip[0].public_ip) : ""
}
output "member_a_url" {
  value = var.allocate_and_associate_eip ? format("https://%s", aws_eip.member_a_eip[0].public_ip) : ""
}
output "member_b_url" {
  value = var.allocate_and_associate_eip ? format("https://%s", aws_eip.member_b_eip[0].public_ip) : ""
}