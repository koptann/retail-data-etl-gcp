# Terraform Modules

This directory contains reusable Terraform modules for the Retail Data Platform infrastructure.

## Module Architecture

Each module follows these principles:

1. **Single Responsibility** - Each module manages one logical component
2. **Minimal Dependencies** - Modules depend only on what they need
3. **Clear Interfaces** - Well-defined inputs (variables) and outputs
4. **Self-Documenting** - Each module has its own README

## Available Modules

### 1. `iam/` - Identity & Access Management
**Purpose:** Service accounts and IAM bindings

**Creates:**
- Service accounts (cloudbuild-sa, retail-etl-sa, dbt-runner)
- IAM role bindings
- Secret Manager for dbt credentials

**Dependencies:** None (created first)

---

### 2. `storage/` - Data Storage
**Purpose:** GCS buckets and BigQuery datasets/tables

**Creates:**
- GCS bucket for data files
- BigQuery dataset
- Raw tables (raw_invoice, raw_country)
- Lifecycle policies

**Dependencies:** IAM (for service account references)

---

### 3. `compute/` - Compute Resources
**Purpose:** Cloud Run jobs and container registry

**Creates:**
- Artifact Registry repository
- Cloud Run job for dbt execution
- Container configuration with secrets

**Dependencies:** IAM, Storage (for service accounts and dataset)

---

### 4. `orchestration/` - Workflow Orchestration
**Purpose:** Event-driven pipeline orchestration

**Creates:**
- Cloud Workflows definition
- Eventarc trigger on GCS uploads
- Pub/Sub topics

**Dependencies:** Compute, Storage (for workflow logic)

---

### 5. `observability/` - Monitoring & Alerts
**Purpose:** Operational visibility and alerting

**Creates:**
- Cloud Monitoring alert policies
- Log-based metrics
- Budget alerts
- Dashboards

**Dependencies:** Orchestration (for monitored resources)

---

### 6. `data_quality/` - Data Quality Checks
**Purpose:** Validation and quality monitoring

**Creates:**
- Cloud Functions for CSV validation
- Cloud Scheduler for daily checks
- BigQuery views for quality metrics

**Dependencies:** Storage (for dataset access)

---

## Module Usage

### Basic Pattern

```hcl
module "module_name" {
  source = "./modules/module_name"
  
  # Required inputs
  project_id = var.project_id
  region     = var.region
  
  # Module-specific configurations
  # ...
  
  # Common labels
  labels = local.labels
  
  # Dependencies (explicit)
  depends_on = [module.dependency_module]
}
```

### Accessing Module Outputs

```hcl
# Reference outputs from other modules
module "orchestration" {
  source = "./modules/orchestration"
  
  bucket_name = module.storage.bucket_name  # Output from storage module
  # ...
}
```

## Development Guidelines

### Creating a New Module

1. **Create module directory**
   ```bash
   mkdir -p infra/modules/new_module
   ```

2. **Create standard files**
   ```
   new_module/
   ├── main.tf         # Resource definitions
   ├── variables.tf    # Input variables
   ├── outputs.tf      # Output values
   └── README.md       # Documentation
   ```

3. **Document the module**
   - Purpose and responsibilities
   - Input variables with descriptions
   - Output values with descriptions
   - Dependencies
   - Usage examples

4. **Test independently**
   ```bash
   cd infra/modules/new_module
   terraform init
   terraform validate
   terraform fmt
   ```

### Module Best Practices

- ✅ **Use descriptive variable names** - `bucket_name` not `name`
- ✅ **Provide default values** when sensible
- ✅ **Add validation** to variable inputs
- ✅ **Export useful outputs** for other modules
- ✅ **Use comments** to explain complex logic
- ✅ **Follow naming conventions** consistent with GCP
- ✅ **Tag resources** with labels for tracking

### Variable Validation Example

```hcl
variable "region" {
  description = "GCP region for resources"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region (e.g., europe-west1)"
  }
}
```

## Testing Modules

### 1. Format Check
```bash
terraform fmt -check -recursive
```

### 2. Validation
```bash
terraform validate
```

### 3. Plan (Dry Run)
```bash
terraform plan
```

### 4. Targeted Apply (Single Module)
```bash
terraform apply -target=module.module_name
```

## Module Dependency Graph

```
iam (no dependencies)
  ↓
storage (depends on: iam)
  ↓
compute (depends on: iam, storage)
  ↓
orchestration (depends on: compute, storage)
  ↓
observability (depends on: orchestration)

data_quality (depends on: storage)
```

## Troubleshooting

### Module Not Found
```
Error: Module not installed
```
**Solution:** Run `terraform init` to download modules

### Circular Dependency
```
Error: Cycle: module.a → module.b → module.a
```
**Solution:** Refactor to break the cycle, use explicit `depends_on`

### Output Not Available
```
Error: Reference to undeclared output value
```
**Solution:** Check module's `outputs.tf` file, ensure output is defined

## Additional Resources

- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/)
- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
