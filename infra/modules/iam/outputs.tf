# =============================================================================
# IAM Module Outputs
# =============================================================================

output "cloudbuild_sa_email" {
  description = "Email address of Cloud Build service account"
  value       = "${var.cloudbuild_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "retail_etl_sa_email" {
  description = "Email address of Retail ETL service account"
  value       = "${var.retail_etl_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "dbt_runner_sa_email" {
  description = "Email address of dbt runner service account"
  value       = "${var.dbt_runner_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

output "dbt_runner_secret_id" {
  description = "Secret Manager secret ID for dbt runner credentials"
  value       = "dbt-runner-key"
}
