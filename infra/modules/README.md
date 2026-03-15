# Terraform Modules - Domain-Driven Architecture

This directory contains domain-driven Terraform modules organized by **business capability** rather than technical resource types.

## Design Philosophy: Domain-Driven Design

Following DDD principles and microservices architecture patterns, modules are organized by **what they do** (business function) rather than **what they are** (resource type).

### Why Domain-Driven Modules?

Just like in microservices architecture where services are organized by business domain (e.g., "order-service", "payment-service") rather than by technical layer (e.g., "database-service", "api-service"), our infrastructure modules follow the same principle:

- ✅ **Clear ownership** - Each module owns a complete business capability
- ✅ **Cohesive changes** - Resources that change together stay together
- ✅ **Bounded contexts** - Well-defined domain boundaries
- ✅ **Easier reasoning** - Align with how data engineers think about the platform

## Module Structure

\`\`\`
modules/
├── platform/          # DOMAIN: Infrastructure provisioning
├── pipeline/          # DOMAIN: Data orchestration & execution
└── observability/     # DOMAIN: Monitoring & quality (cross-cutting)
\`\`\`

### Module Descriptions

#### \`platform/\` - Infrastructure Foundation
**Business Capability:** Provision all foundational cloud resources

**Resources:**
- **IAM:** Service accounts (cloudbuild-sa, retail-etl-sa, dbt-runner), IAM bindings, Secret Manager
- **Storage:** GCS bucket with lifecycle policies, BigQuery dataset, raw tables with partitioning
- **Container Infrastructure:** Artifact Registry for dbt images

**Domain Boundaries:**
- **Owns:** Infrastructure resources that define platform capacity
- **Does NOT own:** Runtime execution or observability

**Dependencies:** None (foundational module)

---

#### \`pipeline/\` - Orchestration & Execution
**Business Capability:** Orchestrate and execute the ELT data pipeline

**Resources:**
- **Workflows:** Cloud Workflows YAML definitions, orchestration logic
- **Event Triggers:** Eventarc triggers for GCS file uploads
- **Compute:** Cloud Run jobs for dbt execution with secret mounting

**Domain Boundaries:**
- **Owns:** Runtime pipeline execution and event handling
- **Does NOT own:** Infrastructure provisioning or monitoring setup

**Dependencies:** \`platform\` (requires service accounts, storage, Artifact Registry)

---

#### \`observability/\` - Monitoring & Quality
**Business Capability:** Ensure platform reliability and data trustworthiness

**Resources:**
- **Monitoring (Phase 2):** Alert policies, log-based metrics, dashboards, budget alerts
- **Data Quality (Phase 3):** Cloud Functions for validation, Cloud Scheduler, quality metric views

**Domain Boundaries:**
- **Owns:** Monitoring, alerting, data validation across all domains (cross-cutting)
- **Does NOT own:** Infrastructure or pipeline execution

**Dependencies:** \`platform\` and \`pipeline\` (needs resources to monitor)

---

## Dependency Graph

\`\`\`
┌─────────────┐
│  platform   │  (no dependencies)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  pipeline   │  (depends: platform)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│observability│  (depends: platform, pipeline)
└─────────────┘
\`\`\`

## Comparison: Domain-Driven vs. Technical Layers

### Domain-Driven Modules (This Approach)
\`\`\`
platform/       → "Build the infrastructure"
pipeline/       → "Run the data pipeline"
observability/  → "Monitor and validate"
\`\`\`
**Organized by:** Business capability (WHAT it does)

**Benefits:**
- Matches data engineering mental model
- Cohesive changesets (IAM + storage + compute for one feature)
- Aligns with DDD bounded contexts
- Follows industry patterns (Netflix, Airbnb, Uber data platforms)

### Technical Layer Modules (Alternative)
\`\`\`
iam/            → "Identity resources"
storage/        → "Storage resources"
compute/        → "Compute resources"
orchestration/  → "Orchestration resources"
\`\`\`
**Organized by:** Resource type (WHAT it is)

**Trade-offs:**
- Matches GCP service boundaries
- Common in generic Terraform examples
- Scatters related changes across multiple modules
- Better for platform teams serving multiple applications

## Usage Patterns

### Root Module Composition

\`\`\`hcl
# infra/main.tf
module "platform" {
  source = "./modules/platform"
  # ... configuration
}

module "pipeline" {
  source = "./modules/pipeline"
  
  # Dependencies from platform
  retail_etl_sa_email = module.platform.retail_etl_sa_email
  bucket_name         = module.platform.bucket_name
  # ... more config
}

module "observability" {
  source = "./modules/observability"
  
  # Dependencies from both modules
  workflow_name = module.pipeline.workflow_name
  dataset_id    = module.platform.dataset_id
  # ... more config
}
\`\`\`

### Module Interface Contract

Each module follows a consistent contract:

1. **README.md** - Module purpose, resources, domain boundaries
2. **main.tf** - Resource definitions with TODO comments
3. **variables.tf** - Input parameters (grouped by concern)
4. **outputs.tf** - Exported values for downstream modules

## Testing Strategy

Each module should be testable in isolation:

- **Platform:** "Can I create service accounts and storage?"
- **Pipeline:** "Can workflows be triggered and execute successfully?"
- **Observability:** "Are alerts firing on simulated failures?"

## Industry Alignment

This structure mirrors data platform patterns from:

- **Netflix:** \`data-collection/\`, \`data-processing/\`, \`data-access/\`
- **Airbnb:** \`ingestion/\`, \`processing/\`, \`serving/\`
- **Uber:** \`onboarding/\`, \`compute/\`, \`consumption/\`

All organized by **pipeline stages** and **business capabilities**, not technical resource types.

## Evolution Path

### Phase 1: Core Implementation
- Implement \`platform\` module (IAM + storage + AR)
- Implement \`pipeline\` module (workflows + triggers + Cloud Run)
- Basic \`observability\` structure

### Phase 2: Enhanced Observability
- Add monitoring dashboards
- Implement alert policies
- Add budget alerts

### Phase 3: Data Quality
- Add validation functions
- Implement quality metrics
- Add anomaly detection

## Questions?

For detailed implementation guidance, see each module's README.md file.
