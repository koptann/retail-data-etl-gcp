# Retail Data Platform - Infrastructure

**Domain-Driven Terraform Architecture**

This folder contains the Terraform infrastructure code for the Retail Data Platform, organized following **Domain-Driven Design** principles.

## Phase 0 Status: Domain-Driven Module Structure ✅

### Architecture Philosophy

Modules are organized by **business capability** (what they DO), not technical resource type (what they ARE):

```
modules/
├── platform/        # DOMAIN: Infrastructure provisioning (BUILD)
├── pipeline/        # DOMAIN: Data orchestration & execution (RUN)
└── observability/   # DOMAIN: Monitoring & quality (OBSERVE)
```

This mirrors patterns used by Netflix, Airbnb, and Uber for their data platforms, and follows Domain-Driven Design bounded contexts.

### What's Created

- **Root module** (`main.tf`) - Composes three domain modules
- **Variables** (`variables.tf`) - Configurable parameters
- **Outputs** (`outputs.tf`) - Exported values
- **Backend configuration** (`backend.tf`) - Remote state setup
- **Example configuration** (`terraform.tfvars.example`) - Template for values

### Domain Modules

#### `platform/` - Infrastructure Foundation
**Business Capability:** Provision all foundational cloud resources

**Contains:**
- ✅ IAM: Service accounts, role bindings, Secret Manager
- ✅ Storage: GCS bucket, BigQuery dataset, raw tables
- ✅ Container Infrastructure: Artifact Registry

**Status:** Structure complete ✅ | Implementation: Phase 1

---

#### `pipeline/` - Orchestration & Execution
**Business Capability:** Orchestrate and execute the ELT pipeline

**Contains:**
- ✅ Workflows: Cloud Workflows definitions
- ✅ Event Triggers: Eventarc on GCS uploads
- ✅ Compute: Cloud Run jobs for dbt

**Status:** Structure complete ✅ | Implementation: Phase 1

---

#### `observability/` - Monitoring & Quality
**Business Capability:** Ensure platform reliability and data quality

**Contains:**
- 🔄 Monitoring: Alert policies, metrics, dashboards (Phase 2)
- 🔄 Data Quality: Validation, quality checks (Phase 3)

**SDependency Graph

Following Domain-Driven Design bounded contexts:

```
┌─────────────┐
│  platform   │  Infrastructure provisioning (BUILD)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  pipeline   │  Data orchestration & execution (RUN)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│observability│  Monitoring & quality (OBSERVE)
└─────────────┘
```

Clean dependency flow: platform → pipeline → observability

## Next Steps

### Phase 1: Implement Core Domains

1. **Platform Module** - IAM + storage + Artifact Registry
2. **Pipeline Module** - Workflows + triggers + Cloud Run jobscp terraform.tfvars.example terraform.tfvars
   `Domain-Driven** - Modules organized by business capability  
✅ **Cohesive** - Resources that change together stay together  
✅ **Bounded Contexts** - Clear domain boundaries (like microservices)  
✅ **Testable** - Each module testable independently  
✅ **Industry-Aligned** - Follows Netflix/Airbnb/Uber patterns

## Why Domain-Driven Modules?

Like microservices organized by business domain ("order-service", "payment-service") rather than technical layer ("database-service", "api-service"), our infrastructure follows the same principle.

**Benefits:**
- Matches data engineering mental model (build → run → observe)
- Changes are cohesive (IAM + storage + compute for one feature)
- Easier to reason about ("I need to fix the pipeline? Check `pipeline/`")
- Aligns with how data platforms are actually operated

See `modules/README.md` for detailed architecture documentation.

✅ **Modular** - Each module has single responsibility  
✅ **Reusable** - Modules can be used in other projects  
✅ **Testable** - Each module can be tested independently  
✅ **Documented** - Every module has its own README  
✅ **Secure** - Follows least privilege principles

## Module Dependencies

```
iam (no deps) → storage → compute → orchestration → observability
                     ↓
                data_quality
```

## Notes

- All modules have placeholder implementations
- TODO comments mark where implementation is needed
- Each module follows consistent structure (main.tf, variables.tf, outputs.tf, README.md)
- Module READMEs describe purpose and future implementation
