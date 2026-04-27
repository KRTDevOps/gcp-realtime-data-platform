resource "google_container_cluster" "gke" {
  count    = var.enable_gke ? 1 : 0
  name     = var.gke_cluster_name
  location = var.region

  network    = "default"
  subnetwork = "default"

  remove_default_node_pool = true
  initial_node_count       = 1

  node_locations = var.gke_zones

  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  count    = var.enable_gke ? 1 : 0
  name     = var.gke_node_pool_name
  location = var.region
  cluster  = google_container_cluster.gke[0].name

  node_count = var.gke_node_count

  node_config {
    machine_type = var.gke_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = {
      workload = "realtime-platform"
    }
  }
}
