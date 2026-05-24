# ----------------------------------------------------------------
# IP ADDRESSES
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# EXTERNAL IP ADDRESS  - Public Application
# ----------------------------------------------------------------

# Reserve external public IP address
# https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address
resource "google_compute_address" "public_app" {
  name   = "public-app-static-ip"
  region = "us-central1"
}