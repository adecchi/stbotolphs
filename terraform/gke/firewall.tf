resource "google_compute_firewall" "fw-db-egress" {
  name      = "postgresql-fw-db-egress"
  network   = google_compute_network.vpc.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["5432", "3307"]
  }

  destination_ranges = [
    "${google_sql_database_instance.postgresql-server.ip_address.0.ip_address}/32",
  ]

  priority = 600
}
