# =============================================================================
# PIPELINE MODULE OUTPUTS
# =============================================================================

output "workflow_name" {
  description = "Cloud Workflows workflow name"
  value       = var.workflow_name
}

output "workflow_url" {
  description = "Cloud Workflows execution URL"
  value       = "https://console.cloud.google.com/workflows/workflow/${var.region}/${var.workflow_name}"
}

output "eventarc_trigger_name" {
  description = "Eventarc trigger name"
  value       = "${var.workflow_name}-trigger"
}

output "dbt_job_name" {
  description = "Cloud Run job name for dbt"
  value       = var.dbt_job_name
}

output "dbt_job_url" {
  description = "Cloud Run job console URL"
  value       = "https://console.cloud.google.com/run/jobs/details/${var.region}/${var.dbt_job_name}"
}
