# IAM Module - Service Accounts & Permissions

This module manages all Identity and Access Management (IAM) resources for the Retail Data Platform.

## Purpose

Creates service accounts with proper permissions following the **principle of least privilege** and the **separation of duties** security pattern.

## Architecture

### 3-Tier Service Account Model

```
┌─────────────────────────────────────────────────────────────┐
│ cloudbuild-sa (Infrastructure Manager)                     │
│ - Deploys Terraform changes                                │
│ - Builds and pushes Docker images                          │
│ - Full infrastructure permissions                          │
│ - Used ONLY by Cloud Build                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓ provisions
┌─────────────────────────────────────────────────────────────┐
│ retail-etl-sa (Runtime Orchestrator)                       │
│ - Executes Workflows                                        │
│ - Handles Eventarc triggers                                │
│ - Loads data to BigQuery                                   │
│ - Triggers Cloud Run jobs                                  │
│ - NO infrastructure modification rights                    │
└─────────────────────────────────────────────────────────────┘
                          ↓ triggers
┌─────────────────────────────────────────────────────────────┐
│ dbt-runner (Data Transformer)                              │
│ - BigQuery data operations ONLY                            │
│ - Used by Cloud Run dbt job                                │
│ - Key stored in Secret Manager                             │
│ - Highest level of isolation                               │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

### Service Accounts
- `cloudbuild-sa@PROJECT_ID.iam.gserviceaccount.com`
- `retail-etl-sa@PROJECT_ID.iam.gserviceaccount.com`
- `dbt-runner@PROJECT_ID.iam.gserviceaccount.com`

### IAM Bindings
- Project-level and resource-level role bindings
- Service agent permissions for GCS → Pub/Sub

### Secrets
- `dbt-runner-key` in Secret Manager (for credentials)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| region | GCP region | string | - | yes |
| cloudbuild_sa_name | Cloud Build SA name | string | cloudbuild-sa | no |
| retail_etl_sa_name | Retail ETL SA name | string | retail-etl-sa | no |
| dbt_runner_sa_name | dbt runner SA name | string | dbt-runner | no |
| labels | Resource labels | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudbuild_sa_email | Cloud Build service account email |
| retail_etl_sa_email | Retail ETL service account email |
| dbt_runner_sa_email | dbt runner service account email |
| dbt_runner_secret_id | Secret Manager ID for dbt credentials |

## Usage

```hcl
module "iam" {
  source = "./modules/iam"
  
  project_id = var.project_id
  region     = var.region
  
  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}

# Reference outputs
resource "some_resource" "example" {
  service_account = module.iam.retail_etl_sa_email
}
```

## Permissions Matrix

| Service Account | Can Deploy Infra? | Can Run Workflows? | Can Transform Data? |
|-----------------|-------------------|-------------------|---------------------|
| cloudbuild-sa   | ✅ YES | ❌ NO | ❌ NO |
| retail-etl-sa   | ❌ NO | ✅ YES | ❌ NO |
| dbt-runner      | ❌ NO | ❌ NO | ✅ YES |

## Security Considerations

1. **No Over-Privileged Accounts** - Each SA has only what it needs
2. **Credential Isolation** - dbt-runner key stored securely in Secret Manager
3. **Audit Trail** - Each SA's actions are separately trackable in logs
4. **Blast Radius Containment** - Compromised SA can't affect other layers

## Dependencies

None - This module must be created first.

## Notes

- Enable required APIs before applying this module
- Service accounts need ~60 seconds to propagate (use `time_sleep` resource)
- dbt-runner key must be manually uploaded to Secret Manager after creation
