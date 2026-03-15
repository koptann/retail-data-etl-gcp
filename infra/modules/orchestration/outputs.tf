output "workflow_name" {
  value = var.workflow_name
}

output "eventarc_trigger_name" {
  value = "${var.workflow_name}-trigger"
}
