# =============================================================================
# PLATFORM MODULE - Infrastructure Foundation
# =============================================================================
# Business Domain: Infrastructure provisioning and identity management
# 
# This module provisions all foundational resources required for the data
# platform including IAM, storage, and container infrastructure.
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
# GCP APIs - Enable Required Services
# =============================================================================

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager_api" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "storage_api" {
  service                    = "storage.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "bigquery_api" {
  service                    = "bigquery.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "artifact_registry_api" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "secretmanager_api" {
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "pubsub_api" {
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

# =============================================================================
# PROJECT DATA - For Service Agent Permissions
# =============================================================================

data "google_project" "project" {
  project_id = var.project_id
}

# =============================================================================
# IAM - SERVICE ACCOUNTS (3-Tier Security Model)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Cloud Build SA - Infrastructure Management
# -----------------------------------------------------------------------------
# Runs Cloud Build and Terraform for infrastructure deployment

resource "google_service_account" "cloudbuild_sa" {
  account_id   = var.cloudbuild_sa_name
  display_name = "Cloud Build Infrastructure Manager"
  description  = "Service account for Cloud Build to run Terraform and manage infrastructure"

  depends_on = [google_project_service.iam_api]
}

# Grant Cloud Build SA Editor permissions (infrastructure deployment)
resource "google_project_iam_member" "cloudbuild_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Grant Cloud Build SA specific permissions
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# -----------------------------------------------------------------------------
# 2. Retail ETL SA - Runtime Orchestration
# -----------------------------------------------------------------------------
# Runs Workflows, Eventarc, and Cloud Run job execution

resource "google_service_account" "retail_etl_sa" {
  account_id   = var.retail_etl_sa_name
  display_name = "Retail ETL Orchestrator"
  description  = "Runtime service account for workflow orchestration and Cloud Run job execution"

  depends_on = [google_project_service.iam_api]
}

# GCS permissions
resource "google_project_iam_member" "retail_etl_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# Workflow permissions
resource "google_project_iam_member" "retail_etl_workflow_invoker" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# Eventarc permissions
resource "google_project_iam_member" "retail_etl_eventarc_admin" {
  project = var.project_id
  role    = "roles/eventarc.admin"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# BigQuery permissions (for loading RAW data)
resource "google_project_iam_member" "retail_etl_bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

resource "google_project_iam_member" "retail_etl_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# Cloud Run permissions
resource "google_project_iam_member" "retail_etl_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# -----------------------------------------------------------------------------
# 3. dbt Runner SA - Data Transformation
# -----------------------------------------------------------------------------
# Runs dbt transformations against BigQuery (Principle of Least Privilege)

resource "google_service_account" "dbt_runner_sa" {
  account_id   = var.dbt_runner_sa_name
  display_name = "dbt BigQuery Runner"
  description  = "Dedicated service account for dbt transformations (Principle of Least Privilege)"

  depends_on = [google_project_service.iam_api]
}

# BigQuery permissions for dbt transformations
resource "google_project_iam_member" "dbt_runner_bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_runner_sa.email}"
}

resource "google_project_iam_member" "dbt_runner_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt_runner_sa.email}"
}

# =============================================================================
# IAM - SERVICE AGENT PERMISSIONS
# =============================================================================
# Grant GCP service agents necessary permissions for Eventarc/Pub/Sub

resource "google_project_iam_member" "gcs_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"

  depends_on = [google_project_service.pubsub_api]
}

# =============================================================================
# IAM - SERVICE ACCOUNT PROPAGATION DELAY
# =============================================================================
# Wait for service accounts to propagate across GCP's distributed systems
# Without this, downstream resources may fail with "ServiceAccount not found"

resource "time_sleep" "wait_for_sa_propagation" {
  create_duration = "60s"

  depends_on = [
    google_service_account.cloudbuild_sa,
    google_service_account.retail_etl_sa,
    google_service_account.dbt_runner_sa,
    google_project_iam_member.retail_etl_storage_viewer,
    google_project_iam_member.retail_etl_workflow_invoker,
    google_project_iam_member.retail_etl_eventarc_admin,
    google_project_iam_member.retail_etl_bigquery_data_editor,
    google_project_iam_member.retail_etl_bigquery_job_user,
    google_project_iam_member.retail_etl_run_invoker,
    google_project_iam_member.dbt_runner_bigquery_data_editor,
    google_project_iam_member.dbt_runner_bigquery_job_user
  ]

  triggers = {
    cloudbuild_sa = google_service_account.cloudbuild_sa.id
    retail_etl_sa = google_service_account.retail_etl_sa.id
    dbt_runner_sa = google_service_account.dbt_runner_sa.id
  }
}

# =============================================================================
# SECRET MANAGER - dbt Runner Credentials
# =============================================================================

resource "google_secret_manager_secret" "dbt_runner_key" {
  secret_id = "dbt-runner-sa-key"

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      managed_by      = "terraform"
      component       = "dbt"
      service_account = var.dbt_runner_sa_name
    }
  )

  depends_on = [google_project_service.secretmanager_api]
}

# Grant dbt-runner permission to access its own credentials
resource "google_secret_manager_secret_iam_member" "dbt_runner_secret_accessor" {
  secret_id = google_secret_manager_secret.dbt_runner_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.dbt_runner_sa.email}"
}

# Grant retail-etl-sa permission to MOUNT the secret in Cloud Run
resource "google_secret_manager_secret_iam_member" "retail_etl_mount_secret" {
  secret_id = google_secret_manager_secret.dbt_runner_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.retail_etl_sa.email}"
}

# =============================================================================
# STORAGE - GCS BUCKET
# =============================================================================

resource "google_storage_bucket" "data_bucket" {
  name          = var.bucket_name
  location      = "EU"
  force_destroy = true

  labels = merge(
    var.labels,
    {
      component = "storage"
      data_type = "raw"
    }
  )

  # Lifecycle policy (if enabled)
  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle ? [1] : []
    content {
      condition {
        age = 90 # Archive after 90 days
      }
      action {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
    }
  }

  depends_on = [google_project_service.storage_api]
}

# =============================================================================
# STORAGE - BIGQUERY DATASET
# =============================================================================

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = "Retail Dataset"
  description   = "Retail data warehouse for ELT pipeline"
  location      = "EU"

  labels = merge(
    var.labels,
    {
      component = "bigquery"
      layer     = "raw-and-transformed"
    }
  )

  depends_on = [google_project_service.bigquery_api]
}

# =============================================================================
# STORAGE - BIGQUERY RAW TABLES
# =============================================================================

resource "google_bigquery_table" "raw_country" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "raw_country"
  deletion_protection = false

  labels = merge(
    var.labels,
    {
      layer = "raw"
      table = "country"
    }
  )

  schema = jsonencode([
    {
      name = "id"
      type = "STRING"
    },
    {
      name = "iso"
      type = "STRING"
    },
    {
      name = "name"
      type = "STRING"
    },
    {
      name = "nicename"
      type = "STRING"
    },
    {
      name = "iso3"
      type = "STRING"
    },
    {
      name = "numcode"
      type = "STRING"
    },
    {
      name = "phonecode"
      type = "STRING"
    }
  ])
}

resource "google_bigquery_table" "raw_invoice" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "raw_invoice"
  deletion_protection = false

  labels = merge(
    var.labels,
    {
      layer = "raw"
      table = "invoice"
    }
  )

  schema = jsonencode([
    {
      name = "InvoiceNo"
      type = "STRING"
    },
    {
      name = "StockCode"
      type = "STRING"
    },
    {
      name = "Description"
      type = "STRING"
    },
    {
      name = "Quantity"
      type = "STRING"
    },
    {
      name = "InvoiceDate"
      type = "STRING"
    },
    {
      name = "UnitPrice"
      type = "STRING"
    },
    {
      name = "CustomerID"
      type = "STRING"
    },
    {
      name = "Country"
      type = "STRING"
    }
  ])

  # Note: Partitioning NOT applied to raw tables
  # - Raw tables accept data as-is (all STRING fields for CSV compatibility)
  # - Partitioning is applied to transformed tables created by dbt
  # - dbt tables will have proper DATE/TIMESTAMP types for partitioning
}

# =============================================================================
# CONTAINER INFRASTRUCTURE - ARTIFACT REGISTRY
# =============================================================================

resource "google_artifact_registry_repository" "dbt_images" {
  location      = var.region
  repository_id = var.ar_repo_name
  description   = "Docker repository for dbt container images"
  format        = "DOCKER"

  labels = merge(
    var.labels,
    {
      component = "artifact-registry"
      purpose   = "dbt-containers"
    }
  )

  depends_on = [google_project_service.artifact_registry_api]
}
