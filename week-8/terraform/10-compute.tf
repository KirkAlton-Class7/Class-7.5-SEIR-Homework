# ----------------------------------------------------------------
# COMPUTE
# ----------------------------------------------------------------

# VM - VM Dashboard
resource "google_compute_instance" "vm_dashboard" {
  name                      = "vm-dashboard"
  machine_type              = "e2-medium"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true # Allows Terraform to stop/start the VM for updates that require a stopped state (avoids recreation when possible)

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
  # Configuration for template Files
  #   metadata_startup_script = templatefile("${path.module}/templates/gcp_startup.sh.tpl",
  #   {
  #       template_var_1  = value,
  #       template_var_2  = value,
  #       template_var_3  = value,
  #     }
  #   )

  tags = ["ssh", "http", "http-server"]

  depends_on = [
    google_compute_subnetwork.private,
    google_compute_router_nat.nat
  ]
}


# VM - VM Instance
# Must use the “centOS stream 10” OS image
# The root persistent disk must be 100 GB
# Must be a machine type in the N series (you choose!) N4A
resource "google_compute_instance" "vm_instance" {
  name                      = "vm-instance"
  machine_type              = "n4-standard-2"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true # Allows Terraform to stop/start the VM for updates that require a stopped state (avoids recreation when possible)

  boot_disk {
    initialize_params {
      image = "centos-stream-10"
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

  # Use Theo's startup script file
  metadata_startup_script = file("${path.module}/../scripts/aarons_scripts/userscripts/startup.sh")


  tags = ["ssh", "http", "http-server"]

  depends_on = [
    # Dependency is implicit in the "subnetwork" argument (references google_compute_subnetwork.private.id)
    # google_compute_subnetwork.private,

    # Dependency must be declared explicitly here.
    # VM startup depends on NAT for outbound internet access.
    google_compute_router_nat.nat
  ]
}


# COMPUTE DISK
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk
# https://docs.cloud.google.com/compute/docs/disks/persistent-disks
resource "google_compute_disk" "balanced_app" {
  name = "balanced-app-disk"
  type = "pd-balanced"
  zone = "us-central1-a"
  size = 100

  physical_block_size_bytes = 4096
}

# DISK ATTACHMENT
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk
resource "google_compute_attached_disk" "balanced_app_to_vm_instance" {
  disk     = google_compute_disk.balanced_app.id
  instance = google_compute_instance.vm_instance.id
}