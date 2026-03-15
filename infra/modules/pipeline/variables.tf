variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
}

# -----------------------------------------------------------------------------
# Dependencies from Platform Module
# -----------------------------------------------------------------------------

variable "retail_etl_sa_email" {
  description = "Service account email for pipeline orchestration"
  type        = string
}

variable "dbt_runner_secret_id" {
  description = "Secret Manager secret ID for dbt credentials"
  type        = string
}

variable "bucket_name" {
  description = "GCS bucket name for event triggers"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID for dbt transformations"
  type        = string
}

# -----------------------------------------------------------------------------
# Pipeline Configuration
# -----------------------------------------------------------------------------

variable "workflow_name" {
  description = "Cloud Workflows workflow name"
  type        = string
}

variable "dbt_job_name" {
  description = "Cloud Run job name for dbt execution"
  type        = string
}

variable "dbt_image" {
  description = "Container image for dbt job"
  type        = string
}

# -----------------------------------------------------------------------------
# Resource Tagging
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Resource labels for organization and cost tracking"
  type        = map(string)
  default     = {}
}
