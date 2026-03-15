# =============================================================================
# OBSERVABILITY MODULE OUTPUTS
# =============================================================================

output "alert_policies" {
  description = "Created alert policy IDs (Phase 2)"
  value       = []
}

output "monitoring_dashboard_url" {
  description = "Cloud Monitoring dashboard URL (Phase 2)"
  value       = "https://console.cloud.google.com/monitoring/dashboards"
}

output "quality_check_function" {
  description = "Quality check Cloud Function name (Phase 3)"
  value       = ""
}

output "quality_metrics_view" {
  description = "BigQuery view for quality metrics (Phase 3)"
  value       = ""
}
