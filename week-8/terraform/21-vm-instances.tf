# ================================================================
# COMPUTE — VM INSTANCES
# ================================================================

# ----------------------------------------------------------------
# VM Instance — VM Dashboard
# ----------------------------------------------------------------

# VM - VM Dashboard
resource "google_compute_instance" "vm_dashboard" {
  name                      = "vm-dashboard"
  machine_type              = "e2-medium"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  network_interface {

    access_config {}
  }

  service_account {
    email  = google_service_account.vm_dashboard.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Use my custom startup script file
  metadata_startup_script = file("${path.module}/../scripts/vm_dashboard/userscripts/gcp_startup.sh")

  tags = ["vm-dashboard"]

  depends_on = [
    # Dependency is implicit in the "subnetwork" argument (references google_compute_subnetwork.private.id)
    # google_compute_subnetwork.private,

    # Dependency must be declared explicitly here.
    # VM startup script depends on outbound internet access (requires NAT).
    google_compute_router_nat.nat
  ]
}

# ----------------------------------------------------------------
# VM Instance — Public App VM
# ----------------------------------------------------------------
# VM - VM Instance
# Must use the “centOS stream 10” OS image
# The root persistent disk must be 100 GB
# Must be a machine type in the N series (you choose!) N4A
resource "google_compute_instance" "public_app_vm_a" {
  name                      = "public-app-vm-instance-a"
  machine_type              = "n4-standard-2"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true

  # https://docs.cloud.google.com/compute/docs/disks/persistent-disks
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
  boot_disk {
    initialize_params {
      image = "centos-stream-10"
      type  = "pd-balanced"
      size  = 100
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id

    # Configure static external IP address
    # https://docs.cloud.google.com/compute/docs/ip-addresses/configure-static-external-ip-address#terraform_1
    access_config {
      nat_ip = google_compute_address.public_app.address
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  # Use Aaron's startup script file
  metadata_startup_script = file("${path.module}/../scripts/aarons_scripts/userscripts/startup.sh")

  metadata = {
    homework = "bam-1"
  }

  # Documentation - Tags and Labels
  # https://docs.cloud.google.com/resource-manager/docs/tags/tags-overview
  # https://docs.cloud.google.com/resource-manager/docs/creating-managing-labels
  tags = ["public-app-vm"]

  depends_on = [
    # Dependency is implicit in the "subnetwork" argument (references google_compute_subnetwork.private.id)
    # google_compute_subnetwork.private,

    # Dependency must be declared explicitly here.
    # VM startup script depends on outbound internet access (requires NAT).
    google_compute_router_nat.nat
  ]
}

# ----------------------------------------------------------------
# VM Instance from Template — Public App VM
# ----------------------------------------------------------------
# Documentation - VM Instance from Template
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template

resource "google_compute_instance_from_template" "public_app_vm_b" {
  name = "public-app-vm-instance-b"
  zone = "us-central1-a"

  source_instance_template = google_compute_region_instance_template.public_app.name

  depends_on = [
    # Dependency must be declared explicitly here.
    # VM startup script depends on outbound internet access (requires NAT).
    google_compute_router_nat.nat
  ]
}