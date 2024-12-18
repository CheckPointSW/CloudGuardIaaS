output "ami_id" {
  value = module.launch_cluster_into_vpc.ami_id
}
output "cluster_public_ip" {
  value = module.launch_cluster_into_vpc.cluster_public_ip
}
output "member_a_public_ip" {
  value = module.launch_cluster_into_vpc.member_a_public_ip
}
output "member_b_public_ip" {
  value = module.launch_cluster_into_vpc.member_b_public_ip
}
output "member_a_ssh" {
  value = module.launch_cluster_into_vpc.member_a_ssh
}
output "member_b_ssh" {
  value = module.launch_cluster_into_vpc.member_b_ssh
}
output "member_a_url" {
  value = module.launch_cluster_into_vpc.member_a_url
}
output "member_b_url" {
  value = module.launch_cluster_into_vpc.member_b_url
}