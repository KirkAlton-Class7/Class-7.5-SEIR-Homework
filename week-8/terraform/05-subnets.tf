# ----------------------------------------------------------------
# SUBNETS
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# SUBNETS - VM SUBNETS
# ----------------------------------------------------------------

resource "google_compute_subnetwork" "private" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = "us-central1"
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}