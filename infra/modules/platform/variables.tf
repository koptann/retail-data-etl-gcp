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

variable "dbt_job_name" {
  description = "Cloud Run dbt job name"
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

# -----------------------------------------------------------------------------
# CI/CD Configuration
# -----------------------------------------------------------------------------

variable "workflow_name" {
  description = "Workflow name to pass to Cloud Build"
  type        = string
}

variable "create_cloud_build_trigger" {
  description = "Create Cloud Build trigger for GitOps automation"
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = ""
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "cloudbuild_trigger_branch" {
  description = "Git branch pattern to trigger builds"
  type        = string
  default     = "^main$"
}

variable "tf_state_bucket" {
  description = "GCS bucket for Terraform state"
  type        = string
  default     = ""
}

variable "tf_state_prefix" {
  description = "Prefix for Terraform state files"
  type        = string
  default     = "terraform/infra"
}

# -----------------------------------------------------------------------------
# Observability Configuration
# -----------------------------------------------------------------------------

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD for cost alerts"
  type        = number
  default     = 100
}
