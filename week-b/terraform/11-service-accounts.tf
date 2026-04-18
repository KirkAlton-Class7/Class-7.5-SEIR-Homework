# ----------------------------------------------------------------
# SERVICE ACCOUNTS - IDENTITY LAYER
# ----------------------------------------------------------------
# REMEMBER:
# Service Accounts = WHO you are
# IAM Roles        = WHAT you can do

# ----------------------------------------------------------------
# SERVICE ACCOUNT - KUBERNETES NODES (INFRASTRUCTURE IDENTITY)
# ----------------------------------------------------------------
# Used by GKE node VMs
# Allows nodes to interact with GCP (logging, pulling images, etc.)
#
# IMPORTANT:
# This is NOT used directly by pods (unless Workload Identity is NOT configured)
# Keep permissions minimal (principle of least privilege)
# ----------------------------------------------------------------

resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes"
  display_name = "Kubernetes Node Service Account"
}

# ----------------------------------------------------------------
# SERVICE ACCOUNT - WORKLOAD (POD IDENTITY)
# ----------------------------------------------------------------
# Used by: Kubernetes ServiceAccount: staging/service-a
# Represents the identity of a specific workload when calling GCP APIs
#
# Naming: account_id matches KSA name for easier mental mapping
# Flow: Pod → KSA (service-a) → GSA (service-a) → IAM roles
# ----------------------------------------------------------------

resource "google_service_account" "gsa_service_a" {
  project      = "kirk-devsecops-sandbox"
  account_id   = "service-a"  # <-- choose your identity name here
  display_name = "GSA for KSA staging/service-a"
}

# ----------------------------------------------------------------
# IAM ROLES
# ----------------------------------------------------------------
# IMPORTANT: Roles are attached to GSAs (not KSAs)
# Keep roles as narrow as possible (tighten later)


# ----------------------------------------------------------------
# IAM ROLE - STORAGE ADMIN (WORKLOAD PERMISSIONS)
# ----------------------------------------------------------------
# Grants full access to Cloud Storage (broad, but good for practice)
# Applies to GSA: service-a
# Replace later with narrower roles (objectViewer, objectAdmin, etc.)
# ----------------------------------------------------------------

resource "google_project_iam_member" "service_a_storage_admin" {
  project = "kirk-devsecops-sandbox"
  role    = "roles/storage.admin"

  member  = "serviceAccount:${google_service_account.gsa_service_a.email}"
}

# ----------------------------------------------------------------
# WORKLOAD IDENTITY - TRUST BINDING (KSA ↔ GSA)
# ----------------------------------------------------------------
# The CRITICAL bridge between:
# Kubernetes identity (KSA)
# Google Cloud identity (GSA)
#
# Without this, pods cannot assume the GSA identity
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# WORKLOAD IDENTITY BINDING
# ----------------------------------------------------------------
# Allows KSA: staging/service-ato impersonate:
# GSA: service-a@kirk-devsecops-sandbox
#
# IMPORTANT:
# Uses CLUSTER PROJECT (not resource project)
# 
# Format:
# serviceAccount:<PROJECT>.svc.id.goog[NAMESPACE/KSA_NAME]
#
# Common failure point:
# - Wrong project in member string
# - Namespace mismatch
# - KSA name mismatch
# ----------------------------------------------------------------

resource "google_service_account_iam_member" "service_a_workload_identity" {
  service_account_id = google_service_account.gsa_service_a.id
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:kirk-devsecops-sandbox.svc.id.goog[staging/service-a]"
}