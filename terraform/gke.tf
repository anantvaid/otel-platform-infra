resource "google_container_cluster" "primary" {
    name     = var.cluster_name
    location = var.zone
    
    networking_mode = "VPC_NATIVE"
    network         = google_compute_network.vpc_network.id
    subnetwork      = google_compute_subnetwork.vpc_subnet.id
    
    deletion_protection = false

    remove_default_node_pool = true
    initial_node_count       = 1

    node_config {
        disk_size_gb = 20  
        disk_type    = "pd-balanced"
    }
    
    ip_allocation_policy {
        cluster_secondary_range_name  = "pod-range"
        services_secondary_range_name = "service-range"
    }

    workload_identity_config {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
}

resource "google_container_node_pool" "primary_nodes" {
    name       = "${var.cluster_name}-spot-node-pool"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    node_count = 2

    node_config {
        machine_type = "e2-standard-4"
        disk_size_gb = 50
        disk_type    = "pd-balanced"

        spot = true

        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform",
        ]

        tags = ["gke-node", "${var.cluster_name}-node"]
    }

    management {
        auto_repair  = true
        auto_upgrade = true
    }
}