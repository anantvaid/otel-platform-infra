resource "google_compute_network" "vpc_network" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name        = "${var.cluster_name}-subnet"
  region = var.region
  network = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/24"

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.1.0.0/16"
  }

    secondary_ip_range {
        range_name    = "service-range"
        ip_cidr_range = "10.2.0.0/20"
    }
}

resource "google_compute_firewall" "allow_health_checks" {
 name    = "allow-gke-health-checks"
 network = google_compute_network.vpc_network.name

 allow {
   protocol = "tcp"
   ports    = ["80", "443", "8080", "8089", "10254"]
 }

 source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

 target_tags   = ["gke-node", "${var.cluster_name}-node"]
}

resource "google_compute_global_address" "gateway_ip" {
  name = "sre-portfolio-gateway-ip"
}