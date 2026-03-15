# Bootstrap & Deployment Guide

## Prerequisites

- GCP Project (create one if needed: https://console.cloud.google.com/projectcreate)
- gcloud CLI installed and authenticated
- Terraform >= 1.6 installed
- Billing enabled on the project
- Project Editor/Owner permissions

## Project Configuration

**⚠️ Replace these example values with your actual configuration in `terraform.tfvars`**

| Setting | Example Value | Description |
|---------|---------------|-------------|
| **Project ID** | `your-gcp-project-id` | Your GCP project identifier |
| **Region** | `europe-west1` | GCP region for resources |
| **Environment** | `dev` | Environment (dev/staging/prod) |
| **Owner** | `your-name` | Resource owner tag |

## Step 1: Authenticate with GCP

```bash
# Authenticate with your Google account
gcloud auth login

# Set default project (replace with your project ID)
gcloud config set project YOUR_PROJECT_ID

# Authenticate application default credentials (for Terraform)
gcloud auth application-default login
```

## Step 2: Bootstrap - Create Terraform State Bucket

This is a **one-time setup** to create the GCS bucket for storing Terraform state remotely.

```bash
# Create GCS bucket for Terraform state (replace YOUR_PROJECT_ID)
gcloud storage buckets create gs://YOUR_PROJECT_ID-tfstate \
  --project=YOUR_PROJECT_ID \
  --location=EU \
  --uniform-bucket-level-access

# Enable versioning for state safety (rollback capability)
gcloud storage buckets update gs://YOUR_PROJECT_ID-tfstate \
  --versioning

# Verify bucket was created
gcloud storage ls --project=YOUR_PROJECT_ID
```

**Expected output:**
```
gs://YOUR_PROJECT_ID-tfstate/
```

## Step 3: Initialize Terraform

Navigate to the infrastructure directory and initialize Terraform with the remote backend.

```bash
cd infra/

# Copy example configuration and customize it
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values (gitignored for security)

# Initialize Terraform with GCS backend (replace YOUR_PROJECT_ID)
terraform init \
  -backend-config="bucket=YOUR_PROJECT_ID-tfstate" \
  -backend-config="prefix=terraform/platform"
```

**Expected output:**
```
Initializing the backend...
Successfully configured the backend "gcs"!

Initializing provider plugins...
- Finding hashicorp/google versions matching "~> 5.0"...
- Finding hashicorp/time versions matching "~> 0.9"...
- Installing hashicorp/google v5.x.x...
- Installing hashicorp/time v0.9.x...

Terraform has been successfully initialized!
```

## Step 4: Validate Configuration

```bash
# Check for syntax errors
terraform validate

# Format code (optional)
terraform fmt -recursive
```

**Expected output:**
```
Success! The configuration is valid.
```

## Step 5: Preview Changes (Dry Run)

```bash
# Generate and review execution plan
terraform plan
```

**Expected output:**
```
Terraform will perform the following actions:

  # module.platform.google_artifact_registry_repository.dbt_images will be created
  # module.platform.google_bigquery_dataset.dataset will be created
  # module.platform.google_bigquery_table.raw_country will be created
  # module.platform.google_bigquery_table.raw_invoice will be created
  # module.platform.google_project_iam_member.cloudbuild_builder will be created
  # ... (45 resources total)

Plan: 45 to add, 0 to change, 0 to destroy.
```

**⚠️ Review carefully before proceeding!**

## Step 6: Deploy Platform Module

```bash
# Apply Terraform configuration (will prompt for confirmation)
terraform apply

# OR auto-approve (use with caution)
terraform apply -auto-approve
```

**Expected duration:** 3-5 minutes

**Resources created:**
- 7 GCP APIs enabled
- 3 Service Accounts
- 12 IAM role bindings
- 1 Secret Manager secret
- 1 GCS bucket (YOUR_BUCKET_NAME)
- 1 BigQuery dataset (YOUR_DATASET_ID)
- 2 BigQuery raw tables
- 1 Artifact Registry repository (replace YOUR_PROJECT_ID and YOUR_DATASET_ID with your values):

```bash
# Check service accounts
gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# Check GCS bucket (use bucket name from terraform.tfvars)
gcloud storage ls gs://YOUR_BUCKET_NAME

# Check BigQuery dataset
bq ls --project_id=YOUR_PROJECT_ID YOUR_DATASET_ID

# Check BigQuery tables
bq ls --project_id=YOUR_PROJECT_ID YOUR_DATASET_ID

# Check Artifact Registry
gcloud artifacts repositories list --project=YOUR_PROJECT_ID --location=europe-west1

# Check Secret Manager
gcloud secrets list --project=YOUR_PROJECT_ID

# View Terraform outputs
terraform output
```

**Expected service accounts (example):**
```
cloudbuild-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
retail-etl-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
dbt-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

**Expected BigQuery tables (example):**
```
YOUR_DATASET_ID.raw_country
YOUR_DATASET_ID
**Expected BigQuery tables:**
```
mtech_retail_dsy.raw_country
mtech_retail_dsy.raw_invoice
```

## Troubleshooting

### Issue: "APIs not enabled"

**Error:** `Error 403: ... API has not been used in project ... before or it is disabled`

**Solution:** Terraform will enable APIs automatically. Retry:
```bash
terraform apply
```

### Issue: "Permission denied"

**Error:** `Error 403: ... does not have storage.buckets.create access`

**Solution:** Ensure you're authenticated and have Editor/Owner permissions:
```bash
gcloud auth application-default login
gcloud projects get-iam-policy YOUR_PROJECT_ID --flatten="bindings[].members" --filter="bindings.members:user:YOUR_EMAIL"
```

### Issue: Bucket already exists

**Error:** `Error creating bucket: googleapi: Error 409: You already own this bucket`

**Solution:** The bucket already exists. Either:
1. Use the existing bucket, or
2. Import it into Terraform state:
```bash
terraform import module.platform.google_storage_bucket.data_bucket YOUR_BUCKET_NAME
```

## Clean Up (Destroy Resources)

**⚠️ WARNING: This will delete all resources!**

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

## State Management

### View State

```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show module.platform.google_service_account.retail_etl_sa
```

### Remote State Location

State is stored in: `gs://YOUR_PROJECT_ID-tfstate/terraform/platform/default.tfstate`

### Migrate to Local State (if needed)

```bash
# Comment out backend block in backend.tf
# Then:
terraform init -migrate-state
```

## Next Steps

After successful Platform module deployment:

1. ✅ Commit the changes (terraform.tfvars is gitignored)
2. ✅ Test manually - Upload a CSV to GCS, verify access to BigQuery
3. 🔄 Implement Pipeline module - Workflows, Eventarc, Cloud Run job
4. 🔄 Implement Observability module - Monitoring and data quality

## Quick Reference

```bash
# Navigate to infra directory
cd infra/

# Initialize (first time only, replace YOUR_PROJECT_ID)
terraform init -backend-config="bucket=YOUR_PROJECT_ID-tfstate" -backend-config="prefix=terraform/platform"

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy everything
terraform destroy
```

## Resources Created

### Platform Module (45 resources)

```
GCP APIs (7):
├── iam.googleapis.com
├── cloudresourcemanager.googleapis.com
├── storage.googleapis.com
├── bigquery.googleapis.com
├── artifactregistry.googleapis.com
├── secretmanager.googleapis.com
└── pubsub.googleapis.com

Service Accounts (3):
├── cloudbuild-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
├── retail-etl-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
└── dbt-runner@YOUR_PROJECT_ID.iam.gserviceaccount.com

IAM Bindings (12):
├── cloudbuild-sa: Editor, Cloud Build Builder
├── retail-etl-sa: Storage Viewer, Workflows Invoker, Eventarc Admin, 
│                  BigQuery Data Editor, BigQuery Job User, Run Invoker
└── dbt-runner: BigQuery Data Editor, BigQuery Job User

Storage:
├── GCS Bucket: gs://YOUR_BUCKET_NAME
│   └── Lifecycle: Archive to COLDLINE after 90 days
├── BigQuery Dataset: YOUR_DATASET_ID (EU)
└── BigQuery Tables:
    ├── raw_country (7 fields)
    └── raw_invoice (8 fields)

Container Infrastructure:
└── Artifact Registry: europe-west1-docker.pkg.dev/YOUR_PROJECT_ID/YOUR_REGISTRY_NAME

Secrets:
└── Secret Manager: dbt-runner-sa-key
```
