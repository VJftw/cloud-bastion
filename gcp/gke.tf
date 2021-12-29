resource "google_project_service" "container" {
  project = local.project_id

  service = "container.googleapis.com"

  disable_dependent_services = true

  // wait 30s to ensure container.googleapis.com is enabled.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "google_container_cluster" "primary" {
  project = local.project_id

  name     = "cluster${local.suffix}"
  location = local.region

  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.subnetwork["private"].self_link

  networking_mode = "VPC_NATIVE"

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  # database_encryption {
  #   state = "ENCRYPTED"
  #   key_name = ""
  # }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  ip_allocation_policy {
    # cluster_ipv4_cidr_block = ""
    # services_ipv4_cidr_block = ""
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.32/28"
    master_global_access_config {
      enabled = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.subnetwork["public"].ip_cidr_range
      display_name = "public subnetwork"  
    } 
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  depends_on = [
    google_project_service.container,
  ]
}

resource "google_compute_firewall" "gke_allow_egress_to_master" {
  project = local.project_id

  name    = "gke-allow-egress-to-master"
  network = google_compute_network.main.name

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["172.16.0.32/28"]
}


resource "google_service_account" "primary" {
  project = local.project_id

  account_id   = "primary-nodes${local.suffix}"
  display_name = "primary nodes in ${google_container_cluster.primary.name}"
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project = local.project_id

  name       = "primary${local.suffix}"
  location   = local.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.primary.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
