output "gke_cluster_name" {
  description = "Name of the provisioned GKE cluster (if enabled)"
  value       = var.enable_gke ? google_container_cluster.gke[0].name : null
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the provisioned GKE cluster (if enabled)"
  value       = var.enable_gke ? google_container_cluster.gke[0].endpoint : null
}

output "custom_vpc_name" {
  description = "Name of custom VPC if enabled"
  value       = var.enable_custom_networking ? google_compute_network.realtime_vpc[0].name : null
}

output "dataflow_service_account_email" {
  description = "Dataflow runner service account email if enabled"
  value       = var.enable_platform_service_accounts ? google_service_account.dataflow_sa[0].email : null
}
