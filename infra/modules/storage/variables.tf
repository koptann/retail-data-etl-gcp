variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "enable_partitioning" {
  type    = bool
  default = true
}

variable "enable_lifecycle" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
