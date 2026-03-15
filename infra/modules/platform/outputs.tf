# =============================================================================
# PLATFORM MODULE OUTPUTS
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "cloudbuild_sa_email" {
  description = "Cloud Build service account email"
  value       = "${var.cloudbuild_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "retail_etl_sa_email" {
  description = "Retail ETL orchestration service account email"
  value       = "${var.retail_etl_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "dbt_runner_sa_email" {
  description = "dbt runner service account email"
  value       = "${var.dbt_runner_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "dbt_runner_secret_id" {
  description = "Secret Manager secret ID for dbt runner credentials"
  value       = "dbt-runner-sa-key"
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "bucket_name" {
  description = "GCS bucket name"
  value       = var.bucket_name
}

output "bucket_url" {
  description = "GCS bucket URL"
  value       = "gs://${var.bucket_name}"
}

output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = var.dataset_id
}

output "dataset_location" {
  description = "BigQuery dataset location"
  value       = "EU"
}

output "raw_tables" {
  description = "List of raw table names"
  value       = ["raw_invoice", "raw_country"]
}

# -----------------------------------------------------------------------------
# Container Infrastructure Outputs
# -----------------------------------------------------------------------------

output "ar_repository_id" {
  description = "Artifact Registry repository ID"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repo_name}"
}

output "ar_repository_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repo_name}"
}
