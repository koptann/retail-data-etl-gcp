# =============================================================================
# PIPELINE MODULE - Orchestration & Execution
# =============================================================================
# Business Domain: Data pipeline orchestration and execution
# 
# This module manages all resources for orchestrating and executing the ELT
# pipeline including workflows, event triggers, and serverless compute.
# =============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# =============================================================================
# GCP APIs - Enable Pipeline-Specific Services
# =============================================================================

resource "google_project_service" "workflows_api" {
  project                    = var.project_id
  service                    = "workflows.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloud_run_api" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "eventarc_api" {
  project            = var.project_id
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# API Propagation Delay
# -----------------------------------------------------------------------------
# Wait for Pipeline APIs to propagate before creating dependent resources

resource "time_sleep" "wait_for_pipeline_apis" {
  create_duration = "90s"

  depends_on = [
    google_project_service.workflows_api,
    google_project_service.cloud_run_api,
    google_project_service.eventarc_api
  ]
}

# =============================================================================
# LOCALS
# =============================================================================

locals {
  # Template workflow YAML with runtime variables
  workflow_yaml = templatefile("${path.module}/workflow.yaml", {
    dataset_id    = var.dataset_id
    region        = var.region
    dbt_job_name  = var.dbt_job_name
    bucket_name   = var.bucket_name
    workflow_name = var.workflow_name
  })
}

# =============================================================================
# CLOUD WORKFLOWS - Orchestration Engine
# =============================================================================

resource "google_workflows_workflow" "etl_pipeline" {
  name            = var.workflow_name
  description     = "Retail ETL pipeline - Load raw CSV to BigQuery and execute dbt transformations"
  region          = var.region
  service_account = var.retail_etl_sa_email

  # Workflow definition (YAML)
  source_contents = local.workflow_yaml

  labels = merge(
    var.labels,
    {
      component = "orchestration"
      layer     = "pipeline"
    }
  )

  depends_on = [
    google_project_service.workflows_api,
    time_sleep.wait_for_pipeline_apis
  ]
}

# =============================================================================
# EVENTARC TRIGGER - Event-Driven Automation
# =============================================================================

resource "google_eventarc_trigger" "gcs_file_upload" {
  name            = "${var.workflow_name}-trigger"
  location        = "eu" # Eventarc uses multi-region for GCS events
  service_account = var.retail_etl_sa_email

  # Trigger on GCS object finalized (file upload complete)
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }

  # Filter to specific bucket
  matching_criteria {
    attribute = "bucket"
    value     = var.bucket_name
  }

  # Execute workflow when triggered
  destination {
    workflow = google_workflows_workflow.etl_pipeline.id
  }

  labels = merge(
    var.labels,
    {
      component  = "eventarc"
      layer      = "pipeline"
      trigger_on = "gcs-upload"
    }
  )

  depends_on = [
    google_project_service.eventarc_api,
    time_sleep.wait_for_pipeline_apis
  ]
}

# =============================================================================
# CLOUD RUN JOB - dbt Execution Environment
# =============================================================================

resource "google_cloud_run_v2_job" "dbt_runner" {
  name     = var.dbt_job_name
  location = var.region

  template {
    template {
      # Job runs AS retail-etl-sa (for Cloud Run orchestration)
      service_account = var.retail_etl_sa_email
      max_retries     = 1
      timeout         = "1800s" # 30 minutes max

      containers {
        image = var.dbt_image
        args  = ["run"] # dbt run command

        # Mount secret containing dbt-runner credentials
        volume_mounts {
          name       = "dbt-sa-secret"
          mount_path = "/secrets"
        }

        # Environment variables for dbt BigQuery connection
        env {
          name  = "GOOGLE_APPLICATION_CREDENTIALS"
          value = "/secrets/dbt-keyfile"
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "DBT_DATASET"
          value = var.dataset_id
        }

        # Resource limits
        resources {
          limits = {
            cpu    = "2"
            memory = "2Gi"
          }
        }
      }

      # Volume definition for secret (contains dbt-runner key)
      volumes {
        name = "dbt-sa-secret"
        secret {
          secret       = var.dbt_runner_secret_id
          default_mode = 0444 # Read-only
          items {
            version = "latest"
            path    = "dbt-keyfile"
          }
        }
      }
    }
  }

  labels = merge(
    var.labels,
    {
      component = "compute"
      layer     = "pipeline"
      runtime   = "dbt"
    }
  )

  depends_on = [
    google_project_service.cloud_run_api,
    time_sleep.wait_for_pipeline_apis
  ]
}

# =============================================================================
# IAM BINDINGS - Cloud Run Job Permissions
# =============================================================================

# Grant retail-etl-sa permission to invoke the dbt Cloud Run job
resource "google_cloud_run_v2_job_iam_member" "dbt_job_invoker" {
  name     = google_cloud_run_v2_job.dbt_runner.name
  location = google_cloud_run_v2_job.dbt_runner.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.retail_etl_sa_email}"
}
