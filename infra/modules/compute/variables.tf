variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "dbt_job_name" {
  type = string
}

variable "dbt_image" {
  type = string
}

variable "ar_repo_name" {
  type = string
}

variable "retail_etl_sa_email" {
  type = string
}

variable "dbt_runner_secret_id" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
