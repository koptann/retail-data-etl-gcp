output "bucket_name" {
  value = var.bucket_name
}

output "bucket_url" {
  value = "gs://${var.bucket_name}"
}

output "dataset_id" {
  value = var.dataset_id
}

output "dataset_location" {
  value = "EU"
}

output "table_ids" {
  value = ["raw_invoice", "raw_country"]
}
