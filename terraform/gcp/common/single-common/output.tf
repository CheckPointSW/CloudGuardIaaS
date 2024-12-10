output "external_nat_ip" {
  value = google_compute_instance.gateway.network_interface[0].access_config[0].nat_ip
}