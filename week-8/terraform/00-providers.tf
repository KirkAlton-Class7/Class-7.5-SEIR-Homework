# ================================================================
# TERRAFORM PROVIDERS
# ================================================================

# ----------------------------------------------------------------
# Terraform Providers - Google
# ----------------------------------------------------------------
# Documentation - Google Provider
# https://registry.terraform.io/providers/hashicorp/google/latest

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33"
    }
  }
}

# Configuration
provider "google" {
  project = "kirk-devsecops-sandbox"
  region  = "us-central1"
}