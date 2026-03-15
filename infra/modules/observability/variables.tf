variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "workflow_name" {
  type = string
}

variable "dbt_job_name" {
  type = string
}

variable "notification_channels" {
  type    = list(string)
  default = []
}

variable "enable_cost_alerts" {
  type    = bool
  default = true
}

variable "monthly_budget_amount" {
  type    = number
  default = 100
}

variable "labels" {
  type    = map(string)
  default = {}
}
