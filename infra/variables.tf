# =============================================================================
# Global Variables - Retail Data Platform
# =============================================================================

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "koptann"
}

# -----------------------------------------------------------------------------
# Service Account Names
# -----------------------------------------------------------------------------

variable "cloudbuild_sa_name" {
  description = "Name for Cloud Build service account"
  type        = string
  default     = "cloudbuild-sa"
}

variable "retail_etl_sa_name" {
  description = "Name for Retail ETL orchestration service account"
  type        = string
  default     = "retail-etl-sa"
}

variable "dbt_runner_sa_name" {
  description = "Name for dbt runner service account"
  type        = string
  default     = "dbt-runner"
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "bucket_name" {
  description = "Name for the data storage bucket (without project prefix)"
  type        = string
  default     = "retail-etl-data"
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "retail_dsy"
}

variable "enable_partitioning" {
  description = "Enable BigQuery table partitioning for cost optimization"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable GCS lifecycle policies for automatic cleanup"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Compute Configuration
# -----------------------------------------------------------------------------

variable "dbt_job_name" {
  description = "Name for the Cloud Run dbt job"
  type        = string
  default     = "retail-etl-dbt-job"
}

variable "dbt_image" {
  description = "Docker image for dbt job (will be built by Cloud Build)"
  type        = string
  default     = "europe-west1-docker.pkg.dev/PROJECT_ID/dbt-images/dbt-etl-job:latest"
}

variable "ar_repo_name" {
  description = "Artifact Registry repository name for dbt images"
  type        = string
  default     = "dbt-images"
}

# -----------------------------------------------------------------------------
# Orchestration Configuration
# -----------------------------------------------------------------------------

variable "workflow_name" {
  description = "Name for the Cloud Workflow"
  type        = string
  default     = "retail-dsy-workflow"
}

# -----------------------------------------------------------------------------
# Observability Configuration
# -----------------------------------------------------------------------------

variable "notification_channels" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "enable_cost_alerts" {
  description = "Enable billing budget alerts"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Data Quality Configuration
# -----------------------------------------------------------------------------

variable "quality_check_schedule" {
  description = "Cron schedule for data quality checks (Cloud Scheduler)"
  type        = string
  default     = "0 9 * * *" # Daily at 9 AM UTC
}

# -----------------------------------------------------------------------------
# CI/CD Configuration
# -----------------------------------------------------------------------------

variable "github_owner" {
  description = "GitHub repository owner/organization"
  type        = string
  default     = ""
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "tf_state_bucket" {
  description = "GCS bucket for Terraform state"
  type        = string
  default     = ""
}

variable "tf_state_prefix" {
  description = "Prefix for Terraform state in GCS bucket"
  type        = string
  default     = "terraform/infra"
}

# -----------------------------------------------------------------------------
# Resource Tagging
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Common labels to apply to all resources for organization and cost tracking"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    project     = "retail-data-platform"
    owner       = "koptann"
    environment = "dev"
  }
}
