# ================================================================
# OUTPUTS
# ================================================================

# ----------------------------------------------------------------
# Outputs - VM Dashboard
# ----------------------------------------------------------------
output "vm_dashboard_name" {
  description = "Name of Dashboard VM"
  value       = google_compute_instance.vm_dashboard.name
}

output "vm_dashboard_external_ip" {
  description = "External IP address of Dashboard VM"
  value       = google_compute_instance.vm_dashboard.network_interface[0].access_config[0].nat_ip
}

output "vm_dashboard_internal_ip" {
  description = "Internal IP address of Dashboard VM"
  value       = google_compute_instance.vm_dashboard.network_interface[0].network_ip
}
output "vm_dashboard_ssh_command" {
  description = "SSH command to connect to Dashboard VM"
  value       = "gcloud compute ssh ${google_compute_instance.vm_dashboard.name} --zone us-central1-a"
}


# ----------------------------------------------------------------
# Outputs - Public App VM A
# ----------------------------------------------------------------
# Documentation - Compute Instance
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
output "public_app_vm_a_ips" {
  description = "Internal and external IP addresses of Public App VM A"

  value = {
    for k, v in google_compute_instance.public_app_vm_a.network_interface :
    k => {
      # Network interface contains a list of objects.
      # network_ip value (internal IP) is auotmatically assigned if empty.
      # access_config is a list of access configurations. 0 index refers to the first value in the list.
      internal_ip = v.network_ip
      external_ip = v.access_config[0].nat_ip
    }
  }
}


# ----------------------------------------------------------------
# Outputs - Public App VM B
# ----------------------------------------------------------------

output "public_app_vm_b_ips" {
  description = "Internal and external IP addresses of Public App VM B"

  value = {
    for k, v in google_compute_instance_from_template.public_app_vm_b.network_interface :
    k => {
      internal_ip = v.network_ip
      external_ip = v.access_config[0].nat_ip
    }
  }
}

