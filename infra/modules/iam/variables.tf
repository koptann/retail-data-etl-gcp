# =============================================================================
# IAM Module Variables
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
}

variable "cloudbuild_sa_name" {
  description = "Name for Cloud Build service account"
  type        = string
  default     = "cloudbuild-sa"
}

variable "retail_etl_sa_name" {
  description = "Name for Retail ETL service account"
  type        = string
  default     = "retail-etl-sa"
}

variable "dbt_runner_sa_name" {
  description = "Name for dbt runner service account"
  type        = string
  default     = "dbt-runner"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
