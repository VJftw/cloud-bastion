terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.5.0"
    }
  }
}

locals {
  project_id = terraform.workspace == "default" ? "secure-gke" : "secure-gke-pr"

  suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}
