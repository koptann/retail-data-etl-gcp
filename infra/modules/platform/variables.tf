variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "cloudbuild_sa_name" {
  description = "Service account name for Cloud Build"
  type        = string
}

variable "retail_etl_sa_name" {
  description = "Service account name for retail ETL orchestration"
  type        = string
}

variable "dbt_runner_sa_name" {
  description = "Service account name for dbt runner"
  type        = string
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "GCS bucket name for data lake"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "enable_partitioning" {
  description = "Enable table partitioning for cost optimization"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable GCS lifecycle policies"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Container Infrastructure
# -----------------------------------------------------------------------------

variable "ar_repo_name" {
  description = "Artifact Registry repository name"
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
