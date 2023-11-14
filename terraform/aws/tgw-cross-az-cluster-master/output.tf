output "cluster_public_ip" {
  value = module.tgw_cluster_into_vpc.cluster_public_ip
}
output "member_a_public_ip" {
  value = module.tgw_cluster_into_vpc.member_a_public_ip
}
output "member_b_public_ip" {
  value = module.tgw_cluster_into_vpc.member_b_public_ip
}
output "member_a_ssh" {
  value = module.tgw_cluster_into_vpc.member_a_ssh
}
output "member_b_ssh" {
  value = module.tgw_cluster_into_vpc.member_b_ssh
}
output "member_a_url" {
  value = module.tgw_cluster_into_vpc.member_a_url
}
output "member_b_url" {
  value = module.tgw_cluster_into_vpc.member_b_url
}
output "member_a_eni" {
  value = module.tgw_cluster_into_vpc.member_a_eni
}
output "member_b_eni" {
  value = module.tgw_cluster_into_vpc.member_b_eni
}
output "vpc_id" {
  value = module.launch_vpc.vpc_id
}
