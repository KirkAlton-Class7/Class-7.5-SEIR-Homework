# ----------------------------------------------------------------
# ROUTER
# ----------------------------------------------------------------

resource "google_compute_router" "router" {
  name    = "router"
  region  = "us-central1"
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }

  # Dependency is implicit in the "network" argument (references google_compute_network.main.id)
  # depends_on = [
  #   google_compute_network.main
  # ]
}