# Platform Module - Infrastructure Foundation

**Business Domain:** Infrastructure provisioning and identity management

Provisions all foundational cloud resources required for the data platform to operate, including identity & access management, data storage, and container infrastructure.

## Purpose

This module represents the **"Build"** phase - everything needed to establish the infrastructure foundation before running any data pipelines.

## Resources Created

### Identity & Access Management
- ✅ **Service Accounts:** 3-tier security model
  - `cloudbuild-sa` - Infrastructure deployment
  - `retail-etl-sa` - Pipeline orchestration
  - `dbt-runner` - Data transformation execution
- ✅ **IAM Bindings:** Least privilege role assignments
- ✅ **Secret Manager:** Secure credential storage for dbt-runner key

### Data Storage
- ✅ **GCS Bucket:** Raw data lake with lifecycle policies
- ✅ **BigQuery Dataset:** Data warehouse (EU region)
- ✅ **Raw Tables:** `raw_invoice`, `raw_country` with partitioning
- ✅ **Optimizations:** Date-based partitioning, clustering, lifecycle management

### Container Infrastructure
- ✅ **Artifact Registry:** Docker repository for dbt images
- ✅ **Repository Configuration:** Regional (europe-west1), Docker format

## Features

- 🔐 **3-Tier Security Model** - Separation of duties across infrastructure, orchestration, and data layers
- 💾 **Cost-Optimized Storage** - Partitioning, clustering, and lifecycle policies
- 🔒 **Encrypted at Rest** - All data encrypted by default (Google-managed keys)
- 📦 **Container Ready** - Artifact Registry ready for dbt container images

## Domain Boundaries

**This module owns:** Infrastructure resources that define the platform's capacity and foundation

**This module does NOT own:** Runtime pipeline execution or observability (see `pipeline/` and `observability/`)

## Usage

```hcl
module "platform" {
  source = "./modules/platform"

  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  
  cloudbuild_sa_name = var.cloudbuild_sa_name
  retail_etl_sa_name = var.retail_etl_sa_name
  dbt_runner_sa_name = var.dbt_runner_sa_name
  
  bucket_name          = var.bucket_name
  dataset_id           = var.dataset_id
  enable_partitioning  = var.enable_partitioning
  enable_lifecycle     = var.enable_lifecycle
  
  ar_repo_name = var.ar_repo_name
  
  labels = var.labels
}
```

## Inputs

See `variables.tf` for complete list.

## Outputs

- Service account emails
- Secret Manager secret ID
- GCS bucket name and URL
- BigQuery dataset ID
- Artifact Registry repository ID

## Dependencies

**Depends on:** None (foundational module)

**Required by:** `pipeline` module (needs service accounts and storage resources)
