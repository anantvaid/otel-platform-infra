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