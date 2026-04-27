resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  location   = var.region
}

resource "google_bigquery_table" "events" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "events"

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  schema = <<EOF
[
  {"name": "user_id", "type": "INTEGER", "mode": "REQUIRED"},
  {"name": "event", "type": "STRING", "mode": "REQUIRED"},
  {"name": "timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"}
]
EOF
}