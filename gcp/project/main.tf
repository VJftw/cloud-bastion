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
}

module "project" {
  source = "///third_party/terraform/modules/org-infra//modules/account/gcp:gcp"

  domain = "vjpatel.me"

  project_id   = local.project_id
  project_name = local.project_id

  folder_display_name = "sandbox"
}

output "project_id" {
  value = module.project.project_id
}
