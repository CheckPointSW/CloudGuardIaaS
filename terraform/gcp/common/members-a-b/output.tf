output "member_a_name" {
  value = module.member_a.cluster_member_name
}
output "member_a_external_ip" {
  value = module.member_a.cluster_member_ip_address
}

output "member_b_name" {
  value = module.member_b.cluster_member_name
}
output "member_b_external_ip" {
  value = module.member_b.cluster_member_ip_address
}