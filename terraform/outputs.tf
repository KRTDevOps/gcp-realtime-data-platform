output "gke_cluster_name" {
  description = "Name of the provisioned GKE cluster (if enabled)"
  value       = var.enable_gke ? google_container_cluster.gke[0].name : null
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the provisioned GKE cluster (if enabled)"
  value       = var.enable_gke ? google_container_cluster.gke[0].endpoint : null
}
