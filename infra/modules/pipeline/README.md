# Pipeline Module - Orchestration & Execution

**Business Domain:** Data pipeline orchestration and execution

Manages all resources required to orchestrate and execute the ELT data pipeline, including workflow definitions, event-driven triggers, and serverless compute jobs.

## Purpose

This module represents the **"Run"** phase - everything needed to execute the data pipeline and respond to events.

## Resources Created

### Workflow Orchestration
- ✅ **Cloud Workflows:** YAML-defined ELT pipeline orchestration
  - Load raw data to BigQuery
  - Execute dbt transformations
  - Error handling and retry logic
- ✅ **Eventarc Triggers:** Event-driven pipeline execution
  - Trigger on GCS file uploads
  - Automatic pipeline initiation

### Serverless Compute
- ✅ **Cloud Run Job:** Containerized dbt execution
  - Serverless, auto-scaling
  - Secret mounting for credentials
  - Resource-optimized configuration

## Features

- 🔄 **Event-Driven Architecture** - Automatic execution on data arrival
- 📋 **Workflow as Code** - Version-controlled YAML pipeline definitions
- ⚡ **Serverless Compute** - Pay only for execution time, auto-scaling
- 🔁 **Retry & Error Handling** - Built-in resilience patterns
- 📊 **Audit Trail** - Complete execution history in Cloud Logging

## Domain Boundaries

**This module owns:** Runtime pipeline execution, event handling, and workflow orchestration

**This module does NOT own:** Infrastructure provisioning (see `platform/`) or monitoring setup (see `observability/`)

## Usage

```hcl
module "pipeline" {
  source = "./modules/pipeline"

  project_id = var.project_id
  region     = var.region
  
  # Dependencies from platform module
  retail_etl_sa_email = module.platform.retail_etl_sa_email
  dbt_runner_secret_id = module.platform.dbt_runner_secret_id
  bucket_name         = module.platform.bucket_name
  dataset_id          = module.platform.dataset_id
  
  # Pipeline configuration
  workflow_name = var.workflow_name
  dbt_job_name  = var.dbt_job_name
  dbt_image     = var.dbt_image
  
  labels = var.labels
}
```

## Inputs

See `variables.tf` for complete list.

## Outputs

- Cloud Workflows name
- Eventarc trigger name
- Cloud Run job name
- Workflow execution URLs

## Dependencies

**Depends on:** `platform` module (requires service accounts, storage, and Artifact Registry)

**Required by:** None (can trigger independently)

**Used by:** `observability` module (for monitoring and alerting)
