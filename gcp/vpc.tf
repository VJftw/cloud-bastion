resource "google_compute_network" "main" {
  project = local.project_id

  name                            = "main${local.suffix}"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
}

locals {
  region = "europe-west1"
  subnetworks = {
    "public" = {
      "cidr_block" = "10.0.1.0/24"
      "private_ip_google_access" = true
    },
    "private" = {
      "cidr_block" = "10.0.8.0/21"
      "private_ip_google_access" = true
    },
  }
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each = local.subnetworks

  project = local.project_id

  name          = each.key
  ip_cidr_range = each.value["cidr_block"]
  region        = local.region
  network       = google_compute_network.main.id

  private_ip_google_access = lookup(each.value, "private_ip_google_access", false)
}

resource "google_compute_firewall" "default_deny_egress" {
  project = local.project_id

  name      = "default-deny-egress"
  network   = google_compute_network.main.name
  direction = "EGRESS"

  priority = 65535 # lowest priority

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "default_deny_ingress" {
  project = local.project_id

  name      = "default-deny-ingress"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  priority = 65535 # lowest priority

  deny {
    protocol = "all"
  }

  source_ranges  = ["0.0.0.0/0"]
}

# resource "google_compute_firewall" "domain" {
#   for_each = toset(flatten([
#     for subnet, config in local.subnetworks: [
#       for source_subnet in lookup(config, "ingress", []):
#         ["${subnet}:${source_subnet}"] 
#     ]
#   ]))

#   project = local.project_id

#   network = google_compute_network.main.name


#   name = "allow-ingress-to-${split(":", each.key)[0]}-from-${split(":", each.key)[1]}"

#   priority = 65534 # low priority

#   allow {
#     protocol = "all"
#   }

#   /* 
#   We cannot use source_ranges and destination_ranges together :facepalm:. 
#   Therefore, we have to use source_tags and target_tags which are supported together.
#   With this in mind, we have to ensure that resources are tagged with their subnet name.
#   Discuss: resources won't be able to egress by default, so maybe relying on tags is fine.
#   */
#   # source_ranges = [local.subnetworks[split(":", each.key)[1]]["cidr_block"]]
#   # destination_ranges = [local.subnetworks[split(":", each.key)[0]]["cidr_block"]]

#   source_tags = [split(":", each.key)[1]]
#   target_tags = [split(":", each.key)[0]]
# }
