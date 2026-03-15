# Observability Module - Monitoring, Alerting & Data Quality

**Business Domain:** Cross-cutting concerns for platform health and data quality

Provides comprehensive monitoring, alerting, and data quality validation across the entire data platform.

## Purpose

This module represents **cross-cutting concerns** - observability capabilities that span all other domains to ensure platform reliability and data trustworthiness.

## Resources Created (Phase 2 & 3)

### Monitoring & Alerting (Phase 2)
- ✅ **Alert Policies:** Proactive failure detection
  - Workflow execution failures
  - BigQuery job failures
  - Cloud Run job failures
- ✅ **Log-based Metrics:** Custom application metrics
  - Pipeline execution duration
  - Data volume trends
  - Error rates
- ✅ **Budget Alerts:** Cost monitoring and controls
  - Monthly budget thresholds
  - Alert channels (email, Slack)
- ✅ **Dashboards:** Operational visibility
  - Pipeline health overview
  - Resource utilization
  - Data freshness metrics

### Data Quality (Phase 3)
- ✅ **Cloud Functions:** Pre-load validation
  - CSV schema validation
  - Data type checks
  - Required field validation
- ✅ **Cloud Scheduler:** Automated quality checks
  - Daily quality metric calculation
  - Anomaly detection
  - Data freshness monitoring
- ✅ **BigQuery Views:** Quality metrics
  - Completeness checks
  - Accuracy metrics
  - Consistency validation
- ✅ **dbt Tests Integration:** Transformation quality
  - Not-null checks
  - Unique key validation
  - Referential integrity

## Features

- 🚨 **Proactive Alerting** - Detect and notify on failures before business impact
- 💰 **Cost Intelligence** - Budget alerts and cost attribution
- 📊 **Custom Dashboards** - Operational visibility and SLA tracking
- ✅ **Data Quality Gates** - Prevent bad data from entering the warehouse
- 🤖 **Anomaly Detection** - ML-based pattern recognition for data issues

## Domain Boundaries

**This module owns:** Monitoring, alerting, data validation, and quality metrics

**This module does NOT own:** Infrastructure provisioning (see `platform/`) or pipeline execution (see `pipeline/`)

## Usage

```hcl
module "observability" {
  source = "./modules/observability"

  project_id = var.project_id
  region     = var.region
  
  # Dependencies from pipeline module
  workflow_name = module.pipeline.workflow_name
  dbt_job_name  = module.pipeline.dbt_job_name
  
  # Dependencies from platform module
  dataset_id  = module.platform.dataset_id
  bucket_name = module.platform.bucket_name
  
  # Observability configuration
  notification_channels = var.notification_channels
  enable_cost_alerts    = var.enable_cost_alerts
  monthly_budget_amount = var.monthly_budget_amount
  quality_check_schedule = var.quality_check_schedule
  
  labels = var.labels
}
```

## Inputs

See `variables.tf` for complete list.

## Outputs

- Alert policy IDs
- Dashboard URLs
- Quality check function names
- Metric names

## Dependencies

**Depends on:** `platform` and `pipeline` modules (needs resources to monitor)

**Required by:** None (passive observation)

## Implementation Phases

- **Phase 2:** Monitoring dashboards, alert policies, cost budgets
- **Phase 3:** Data quality validation, automated testing, anomaly detection
