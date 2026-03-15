output "dbt_job_name" {
  value = var.dbt_job_name
}

output "ar_repository_id" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repo_name}"
}
