terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.5.0"
    }
  }
}

resource "random_string" "id" {
  length  = 6
  special = false
  upper   = false
}

module "project" {
  source = "///third_party/terraform/modules/org-infra//modules/account/gcp:gcp"

  domain = "vjpatel.me"

  project_id   = "secure-gke-${random_string.id.result}"
  project_name = "Secure GKE ${random_string.id.result}"

  folder_display_name = "sandbox"
}
