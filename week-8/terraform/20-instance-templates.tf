# ================================================================
# COMPUTE — INSTANCE TEMPLATES
# ================================================================

# ----------------------------------------------------------------
# Regional Instance Template — Public App
# ----------------------------------------------------------------
# Use a regional instance template to isolate hardware errors to the template's region.
# This also isolates regional resources from from outaes that affect globally scoped Compute Engine services.
# https://docs.cloud.google.com/compute/docs/instance-templates

# Documentation - Instance Templates
# https://docs.cloud.google.com/compute/docs/instance-templates/create-instance-templates#terraform
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template

resource "google_compute_region_instance_template" "public_app" {
  name         = "public-app-instance-template"
  machine_type = "n4-standard-2"
  description  = "Instance template for public app instances."

  metadata = {
    homework = "bam-2"
  }

  tags = ["public-app-vm"]

  labels = {
    environment = "dev"
  }

  disk {
    source_image = "centos-stream-10"
    disk_type    = "pd-balanced"
    disk_size_gb = 200
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id

    # Configure Static External IP Address
    # Documentation - Extrnal IP Address
    # https://docs.cloud.google.com/vpc/docs/reserve-static-external-ip-address
    # https://docs.cloud.google.com/compute/docs/ip-addresses/configure-static-external-ip-address#terraform_1
    access_config {
      nat_ip = google_compute_address.public_app.address
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}