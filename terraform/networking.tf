resource "google_compute_network" "realtime_vpc" {
  count                   = var.enable_custom_networking ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "realtime_subnet" {
  count         = var.enable_custom_networking ? 1 : 0
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.realtime_vpc[0].id

  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_internal_ingress" {
  count   = var.enable_custom_networking ? 1 : 0
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.realtime_vpc[0].name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.allowed_ingress_cidrs
  target_tags   = ["realtime-platform"]
}
