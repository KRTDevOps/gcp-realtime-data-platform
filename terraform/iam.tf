resource "google_service_account" "dataflow_sa" {
  count        = var.enable_platform_service_accounts ? 1 : 0
  account_id   = var.dataflow_sa_name
  display_name = "Dataflow Runner Service Account"
}

resource "google_service_account" "composer_sa" {
  count        = var.enable_platform_service_accounts ? 1 : 0
  account_id   = var.composer_sa_name
  display_name = "Composer Runtime Service Account"
}

resource "google_service_account" "gke_workload_sa" {
  count        = var.enable_platform_service_accounts ? 1 : 0
  account_id   = var.gke_workload_sa_name
  display_name = "GKE Workload Service Account"
}

resource "google_project_iam_member" "dataflow_worker_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow_sa[0].email}"
}

resource "google_project_iam_member" "dataflow_bigquery_editor_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dataflow_sa[0].email}"
}

resource "google_project_iam_member" "dataflow_pubsub_subscriber_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.dataflow_sa[0].email}"
}

resource "google_project_iam_member" "composer_worker_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_sa[0].email}"
}

resource "google_project_iam_member" "gke_logging_writer_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_workload_sa[0].email}"
}

resource "google_project_iam_member" "gke_monitoring_writer_role" {
  count   = var.enable_platform_service_accounts ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_workload_sa[0].email}"
}

resource "google_project_iam_member" "platform_admin_bindings" {
  for_each = toset(var.iam_admin_principals)

  project = var.project_id
  role    = "roles/editor"
  member  = each.value
}
