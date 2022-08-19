resource "google_compute_firewall" "firewall_rules" {
  name = var.rule_name
  project = var.project
  network = var.network[0]
  allow {
    protocol = var.protocol
  }
  source_ranges = var.source_ranges
  target_tags = [
    "checkpoint-gateway"]
}
