output "cluster_member_name" {
  value = google_compute_instance.cluster_member.name
}
output "cluster_member_ip_address" {
  value = google_compute_address.member_ip_address.address
}
