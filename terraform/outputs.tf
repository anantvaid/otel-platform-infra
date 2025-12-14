output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = google_container_cluster.primary.name
}

output "kubernetes_cluster_host" {
  description = "The endpoint of the Kubernetes cluster"
  value       = google_container_cluster.primary.endpoint
}

output "region" {
  description = "The region where the resources are deployed"
  value       = var.region
}