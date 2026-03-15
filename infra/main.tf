# =============================================================================
# RETAIL DATA PLATFORM - ROOT MODULE
# =============================================================================
# Domain-Driven Architecture - Business Capability Modules
#
# This root module composes three domain modules:
# - platform: Infrastructure provisioning (BUILD)
# - pipeline: Data orchestration & execution (RUN)  
# - observability: Monitoring & quality (OBSERVE)
# =============================================================================

terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# =============================================================================
# MODULE DECLARATIONS - Domain-Driven Architecture
# =============================================================================
# Modules are organized by BUSINESS CAPABILITY (what they DO):
# - platform: Infrastructure provisioning (IAM + storage + container infra)
# - pipeline: Data orchestration & execution (workflows + triggers + compute)
# - observability: Monitoring & quality (cross-cutting concerns)
#
# This follows Domain-Driven Design principles, similar to microservices
# organized by business domain rather than technical layers.
# =============================================================================

# -----------------------------------------------------------------------------
# Platform Module - Infrastructure Foundation
# -----------------------------------------------------------------------------
# Business Domain: Infrastructure provisioning and identity management
# 
# Creates all foundational resources including:
# - IAM: Service accounts, role bindings, Secret Manager
# - Storage: GCS bucket, BigQuery dataset, raw tables
# - Container Infrastructure: Artifact Registry
#
# Dependencies: None (foundational module)

module "platform" {
  source = "./modules/platform"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  # IAM configuration
  cloudbuild_sa_name = var.cloudbuild_sa_name
  retail_etl_sa_name = var.retail_etl_sa_name
  dbt_runner_sa_name = var.dbt_runner_sa_name

  # Storage configuration
  bucket_name         = var.bucket_name
  dataset_id          = var.dataset_id
  enable_partitioning = var.enable_partitioning
  enable_lifecycle    = var.enable_lifecycle

  # Container infrastructure
  ar_repo_name = var.ar_repo_name

  # CI/CD configuration
  create_cloud_build_trigger = var.create_cloud_build_trigger
  github_owner               = var.github_owner
  github_repo_name           = var.github_repo_name
  cloudbuild_trigger_branch  = var.cloudbuild_trigger_branch
  tf_state_bucket            = var.tf_state_bucket
  tf_state_prefix            = var.tf_state_prefix

  labels = var.labels
}

# -----------------------------------------------------------------------------
# Pipeline Module - Orchestration & Execution
# -----------------------------------------------------------------------------
# Business Domain: Data pipeline orchestration and execution
#
# Creates all runtime resources including:
# - Workflows: Cloud Workflows for ELT orchestration
# - Event Triggers: Eventarc triggers on GCS uploads
# - Compute: Cloud Run jobs for dbt execution
#
# Dependencies: platform (requires service accounts, storage, Artifact Registry)

module "pipeline" {
  source = "./modules/pipeline"

  project_id = var.project_id
  region     = var.region

  # Dependencies from platform module
  retail_etl_sa_email  = module.platform.retail_etl_sa_email
  dbt_runner_secret_id = module.platform.dbt_runner_secret_id
  bucket_name          = module.platform.bucket_name
  dataset_id           = module.platform.dataset_id
  platform_ready       = module.platform.platform_ready

  # Pipeline configuration
  workflow_name = var.workflow_name
  dbt_job_name  = var.dbt_job_name
  dbt_image     = var.dbt_image

  labels = var.labels
}

# -----------------------------------------------------------------------------
# Observability Module - Monitoring, Alerting & Data Quality
# -----------------------------------------------------------------------------
# Business Domain: Cross-cutting concerns for platform health and data quality
#
# Creates observability resources including:
# - Monitoring (Phase 2): Alert policies, metrics, dashboards, budget alerts
# - Data Quality (Phase 3): Validation functions, quality checks, anomaly detection
#
# Dependencies: platform, pipeline (needs resources to monitor)

module "observability" {
  source = "./modules/observability"

  project_id = var.project_id
  region     = var.region

  # Dependencies from pipeline module
  workflow_name = module.pipeline.workflow_name
  dbt_job_name  = module.pipeline.dbt_job_name

  # Dependencies from platform module
  dataset_id  = module.platform.dataset_id
  bucket_name = module.platform.bucket_name

  # Observability configuration
  notification_channels  = var.notification_channels
  enable_cost_alerts     = var.enable_cost_alerts
  monthly_budget_amount  = var.monthly_budget_amount
  quality_check_schedule = var.quality_check_schedule

  labels = var.labels
}
