resource "google_bigtable_instance" "instance" {
  name         = var.bigtable_instance_id
  display_name = "Realtime Bigtable"

  cluster {
    cluster_id   = "cluster-1"
    zone         = "${var.region}-a"
    num_nodes    = 1
    storage_type = "SSD"
  }
}

resource "google_bigtable_table" "table" {
  name          = var.bigtable_table_id
  instance_name = google_bigtable_instance.instance.name

  column_family {
    family = "cf1"
  }
}