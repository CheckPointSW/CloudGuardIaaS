output "network" {
  value = google_compute_network.network.name
}
output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.name
}
output "internal_network" {
  value = google_compute_network.internal_network.name
}
output "internal_subnetwork" {
  value = google_compute_subnetwork.internal_subnetwork.name
}
