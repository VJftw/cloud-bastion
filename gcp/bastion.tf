resource "google_compute_instance_template" "bastion" {
  project = local.project_id

  name_prefix        = "bastion"
  description = "This template is used to create bastion instances."

  tags = ["bastion"]

  instance_description = "bastion instances"
  machine_type         = "e2-micro"
  can_ip_forward       = false

  metadata = {
    "enable-oslogin" = "TRUE"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.subnetwork["public"].self_link
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "bastion_iap_ssh" {
  project = local.project_id

  name    = "bastion-allow-ssh-over-iap"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]
}

resource "google_compute_target_pool" "bastion" {
  project = local.project_id

  name = "bastion"

  region = local.region
}

resource "google_compute_region_instance_group_manager" "bastion" {
  project = local.project_id

  name = "bastion"

  base_instance_name = "bastion"
  region             = local.region

  version {
    instance_template = google_compute_instance_template.bastion.id
  }

  target_pools = [google_compute_target_pool.bastion.id]
  target_size  = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.bastion.id
    initial_delay_sec = 300
  }
}

resource "google_compute_health_check" "bastion" {
  project = local.project_id

  name = "bastion"

  check_interval_sec  = 6
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 60 seconds

  tcp_health_check {
    port = "22"
  }
}

resource "google_compute_firewall" "bastion_healthcheck" {
  project = local.project_id

  name    = "bastion-allow-healthcheck"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
