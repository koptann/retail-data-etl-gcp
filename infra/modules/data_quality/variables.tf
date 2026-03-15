variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "quality_check_schedule" {
  type    = string
  default = "0 9 * * *"
}

variable "labels" {
  type    = map(string)
  default = {}
}
