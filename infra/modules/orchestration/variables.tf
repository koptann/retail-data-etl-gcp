variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "workflow_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "dbt_job_name" {
  type = string
}

variable "retail_etl_sa_email" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
