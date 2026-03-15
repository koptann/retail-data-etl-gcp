# =============================================================================
# Root Module Outputs - Retail Data Platform
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------

output "service_accounts" {
  description = "Created service accounts"
  value = {
    cloudbuild_sa = module.iam.cloudbuild_sa_email
    retail_etl_sa = module.iam.retail_etl_sa_email
    dbt_runner_sa = module.iam.dbt_runner_sa_email
  }
}

output "dbt_runner_secret_id" {
  description = "Secret Manager secret ID for dbt runner key"
  value       = module.iam.dbt_runner_secret_id
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------

output "gcs_bucket" {
  description = "GCS bucket for data storage"
  value = {
    name = module.storage.bucket_name
    url  = module.storage.bucket_url
  }
}

output "bigquery_dataset" {
  description = "BigQuery dataset information"
  value = {
    dataset_id = module.storage.dataset_id
    location   = module.storage.dataset_location
    tables     = module.storage.table_ids
  }
}

# -----------------------------------------------------------------------------
# Compute Outputs
# -----------------------------------------------------------------------------

output "cloud_run_job" {
  description = "Cloud Run job for dbt execution"
  value = {
    name   = module.compute.dbt_job_name
    region = var.region
  }
}

output "artifact_registry" {
  description = "Artifact Registry repository"
  value = {
    repository = module.compute.ar_repository_id
    location   = var.region
  }
}

# -----------------------------------------------------------------------------
# Orchestration Outputs
# -----------------------------------------------------------------------------

output "workflow" {
  description = "Cloud Workflow information"
  value = {
    name   = module.orchestration.workflow_name
    region = var.region
  }
}

output "eventarc_trigger" {
  description = "Eventarc trigger for file uploads"
  value = {
    name   = module.orchestration.eventarc_trigger_name
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# Project Information
# -----------------------------------------------------------------------------

output "project_info" {
  description = "Project configuration summary"
  value = {
    project_id  = var.project_id
    region      = var.region
    environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Quick Commands
# -----------------------------------------------------------------------------

output "quick_commands" {
  description = "Useful commands for managing the platform"
  value = <<-EOT
    
    📊 Check pipeline status:
      bq ls --project_id=${var.project_id} ${module.storage.dataset_id}
    
    🔄 View workflow executions:
      gcloud workflows executions list ${module.orchestration.workflow_name} --location=${var.region} --limit=5
    
    🏃 Check Cloud Run job executions:
      gcloud run jobs executions list --job=${module.compute.dbt_job_name} --region=${var.region} --limit=5
    
    📤 Upload test data:
      gsutil cp include/dataset/*.csv gs://${module.storage.bucket_name}/dataset/
    
    📝 View dbt logs:
      gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=${module.compute.dbt_job_name}" --limit=50
    
    💰 Check BigQuery costs:
      bq query --use_legacy_sql=false "SELECT DATE(creation_time) as date, SUM(total_bytes_processed)/POW(10,12) as tb_processed FROM \`region-eu.INFORMATION_SCHEMA.JOBS_BY_PROJECT\` WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) GROUP BY date ORDER BY date DESC"
  EOT
}
