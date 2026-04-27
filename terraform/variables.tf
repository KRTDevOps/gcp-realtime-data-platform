variable "project_id" {
  description = "GCP project ID for all resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project id."
  }
}
variable "region" {
  type    = string
  default = "us-central1"
}

variable "dataset_id" {
  type    = string
  default = "realtime_dataset"
}

variable "bigtable_instance_id" {
  type    = string
  default = "realtime-instance"
}

variable "bigtable_table_id" {
  type    = string
  default = "events"
}

variable "composer_env_name" {
  type    = string
  default = "composer-env"
}

variable "composer_image_version" {
  description = "Composer image version pinned for reproducible deploys"
  type        = string
  default     = "composer-2.9.5-airflow-2.9.3"
}

variable "bucket_name" {
  description = "GCS bucket for Dataflow staging"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,220}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid GCS bucket name."
  }
}

variable "enable_gke" {
  description = "If true, create GKE cluster resources"
  type        = bool
  default     = false
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "realtime-gke"
}

variable "gke_zones" {
  description = "Zones used by the GKE cluster node locations"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b"]
}

variable "gke_node_pool_name" {
  description = "Primary GKE node pool name"
  type        = string
  default     = "default-node-pool"
}

variable "gke_node_count" {
  description = "Initial node count for GKE node pool"
  type        = number
  default     = 2
}

variable "gke_machine_type" {
  description = "Machine type for GKE worker nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "enable_custom_networking" {
  description = "If true, creates a dedicated VPC/subnet/firewall for the platform"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of custom VPC network"
  type        = string
  default     = "realtime-vpc"
}

variable "subnet_name" {
  description = "Name of custom subnet"
  type        = string
  default     = "realtime-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for custom subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "allowed_ingress_cidrs" {
  description = "Allowed source CIDRs for application ingress"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_platform_service_accounts" {
  description = "If true, creates service accounts and baseline IAM grants"
  type        = bool
  default     = true
}

variable "dataflow_sa_name" {
  description = "Dataflow service account id"
  type        = string
  default     = "dataflow-runner"
}

variable "composer_sa_name" {
  description = "Composer service account id"
  type        = string
  default     = "composer-runtime"
}

variable "gke_workload_sa_name" {
  description = "GKE workload service account id"
  type        = string
  default     = "gke-workload"
}

variable "iam_admin_principals" {
  description = "Additional principals (users/groups/serviceAccounts) to receive platform admin role"
  type        = list(string)
  default     = []
}