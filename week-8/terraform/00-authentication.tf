# ----------------------------------------------------------------
# Terraform Configuration
# ----------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33"
    }
  }
}

provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}