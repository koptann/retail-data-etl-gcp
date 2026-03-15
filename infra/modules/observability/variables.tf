variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
}

# -----------------------------------------------------------------------------
# Dependencies from Other Modules
# -----------------------------------------------------------------------------

variable "workflow_name" {
  description = "Cloud Workflows name to monitor"
  type        = string
}

variable "dbt_job_name" {
  description = "Cloud Run job name to monitor"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID for quality checks"
  type        = string
}

variable "bucket_name" {
  description = "GCS bucket name for quality validation"
  type        = string
}

# -----------------------------------------------------------------------------
# Monitoring Configuration
# -----------------------------------------------------------------------------

variable "notification_channels" {
  description = "Cloud Monitoring notification channel IDs"
  type        = list(string)
  default     = []
}

variable "enable_cost_alerts" {
  description = "Enable budget alerting"
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
  description = "Cron schedule for quality checks (Phase 3)"
  type        = string
  default     = "0 9 * * *" # Daily at 9 AM
}

# -----------------------------------------------------------------------------
# Resource Tagging
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Resource labels for organization and cost tracking"
  type        = map(string)
  default     = {}
}
