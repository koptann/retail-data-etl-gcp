# =============================================================================
# PIPELINE MODULE OUTPUTS
# =============================================================================

output "workflow_name" {
  description = "Cloud Workflows workflow name"
  value       = google_workflows_workflow.etl_pipeline.name
}

output "workflow_id" {
  description = "Cloud Workflows workflow ID"
  value       = google_workflows_workflow.etl_pipeline.id
}

output "workflow_url" {
  description = "Cloud Workflows console URL"
  value       = "https://console.cloud.google.com/workflows/workflow/${var.region}/${google_workflows_workflow.etl_pipeline.name}"
}

output "eventarc_trigger_name" {
  description = "Eventarc trigger name"
  value       = google_eventarc_trigger.gcs_file_upload.name
}

output "eventarc_trigger_id" {
  description = "Eventarc trigger ID"
  value       = google_eventarc_trigger.gcs_file_upload.id
}

output "dbt_job_name" {
  description = "Cloud Run job name for dbt"
  value       = google_cloud_run_v2_job.dbt_runner.name
}

output "dbt_job_id" {
  description = "Cloud Run job ID"
  value       = google_cloud_run_v2_job.dbt_runner.id
}

output "dbt_job_url" {
  description = "Cloud Run job console URL"
  value       = "https://console.cloud.google.com/run/jobs/details/${var.region}/${google_cloud_run_v2_job.dbt_runner.name}"
}
