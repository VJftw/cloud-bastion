resource "google_compute_router" "internet" {
  project = module.project.project_id

  name    = "internet"
  region  = google_compute_subnetwork.subnetwork["public"].region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "internet" {
  project = module.project.project_id

  name                   = "internet"
  router                 = google_compute_router.internet.name
  region                 = google_compute_router.internet.region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnetwork["private"].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_route" "internet" {
  project = module.project.project_id

  name = "internet"
  network = google_compute_network.main.id

  dest_range = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_firewall" "nat_allow_internet_egress" {
  project = module.project.project_id

  name      = "nat-allow-internet-egress"
  network   = google_compute_network.main.name
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports = ["443"]
  }

  destination_ranges = ["0.0.0.0/0"]
}
