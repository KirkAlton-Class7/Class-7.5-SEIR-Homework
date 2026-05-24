# ================================================================
# NETWORKING — FIREWALL
# ================================================================

# ----------------------------------------------------------------
# Firewall Rule — VM Dashboard
# ----------------------------------------------------------------

resource "google_compute_firewall" "vm_dashboard" {
  name    = "vm-dashboard"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22, 80, 443, 8080"]
  }

  source_ranges = ["0.0.0.0/0"]

  # Documentation - Tags and Labels
  # https://docs.cloud.google.com/resource-manager/docs/tags/tags-overview
  # https://docs.cloud.google.com/resource-manager/docs/creating-managing-labels
  target_tags = ["vm-dashboard"]
}


# ----------------------------------------------------------------
# Firewall Rule — Public App VM
# ----------------------------------------------------------------

resource "google_compute_firewall" "public_app_vm" {
  name    = "public-app-vm"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22, 80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["public-app-vm"]
}