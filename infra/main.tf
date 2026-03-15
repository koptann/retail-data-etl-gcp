# =============================================================================
# Root Terraform Configuration - Retail Data Platform
# =============================================================================
# This is the main entry point that orchestrates all infrastructure modules
# Follow the principle: thin root module, thick child modules
# =============================================================================

terraform {
  required_version = ">= 1.6"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.13"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  project_id = var.project_id
  region     = var.region
  
  # Common tags for all resources
  labels = {
    project     = "retail-data-platform"
    environment = var.environment
    managed_by  = "terraform"
    owner       = var.owner
  }
  
  # Service accounts
  cloudbuild_sa_email = "${var.cloudbuild_sa_name}@${var.project_id}.iam.gserviceaccount.com"
  retail_etl_sa_email = "${var.retail_etl_sa_name}@${var.project_id}.iam.gserviceaccount.com"
  dbt_runner_sa_email = "${var.dbt_runner_sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

# =============================================================================
# Module: IAM - Service Accounts & Permissions
# =============================================================================
# Creates service accounts first - no dependencies on other resources
# This eliminates the "bootstrap paradox"

module "iam" {
  source = "./modules/iam"
  
  project_id = local.project_id
  region     = local.region
  
  cloudbuild_sa_name = var.cloudbuild_sa_name
  retail_etl_sa_name = var.retail_etl_sa_name
  dbt_runner_sa_name = var.dbt_runner_sa_name
  
  labels = local.labels
}

# =============================================================================
# Module: Storage - GCS Buckets & BigQuery
# =============================================================================
# Creates all storage resources: buckets, datasets, tables

module "storage" {
  source = "./modules/storage"
  
  project_id = local.project_id
  region     = local.region
  
  bucket_name          = var.bucket_name
  dataset_id           = var.dataset_id
  enable_partitioning  = var.enable_partitioning
  enable_lifecycle     = var.enable_lifecycle
  
  labels = local.labels
  
  # Wait for IAM to be ready
  depends_on = [module.iam]
}

# =============================================================================
# Module: Compute - Cloud Run Jobs & Artifact Registry
# =============================================================================
# Creates compute resources for dbt execution

module "compute" {
  source = "./modules/compute"
  
  project_id = local.project_id
  region     = local.region
  
  dbt_job_name        = var.dbt_job_name
  dbt_image           = var.dbt_image
  ar_repo_name        = var.ar_repo_name
  retail_etl_sa_email = module.iam.retail_etl_sa_email
  dbt_runner_secret_id = module.iam.dbt_runner_secret_id
  
  labels = local.labels
  
  depends_on = [module.iam, module.storage]
}

# =============================================================================
# Module: Orchestration - Workflows, Eventarc, Triggers
# =============================================================================
# Creates workflow and event-driven orchestration

module "orchestration" {
  source = "./modules/orchestration"
  
  project_id = local.project_id
  region     = local.region
  
  workflow_name       = var.workflow_name
  bucket_name         = module.storage.bucket_name
  dataset_id          = module.storage.dataset_id
  dbt_job_name        = module.compute.dbt_job_name
  retail_etl_sa_email = module.iam.retail_etl_sa_email
  
  labels = local.labels
  
  depends_on = [module.compute, module.storage]
}

# =============================================================================
# Module: Observability - Monitoring, Alerts, Dashboards
# =============================================================================
# Creates monitoring infrastructure (Phase 2)

module "observability" {
  source = "./modules/observability"
  
  project_id = local.project_id
  region     = local.region
  
  workflow_name          = var.workflow_name
  dbt_job_name           = var.dbt_job_name
  notification_channels  = var.notification_channels
  enable_cost_alerts     = var.enable_cost_alerts
  monthly_budget_amount  = var.monthly_budget_amount
  
  labels = local.labels
  
  depends_on = [module.orchestration]
}

# =============================================================================
# Module: Data Quality - Validation & Testing
# =============================================================================
# Creates data quality infrastructure (Phase 3)

module "data_quality" {
  source = "./modules/data_quality"
  
  project_id = local.project_id
  region     = local.region
  
  dataset_id             = module.storage.dataset_id
  bucket_name            = module.storage.bucket_name
  quality_check_schedule = var.quality_check_schedule
  
  labels = local.labels
  
  depends_on = [module.storage]
}
