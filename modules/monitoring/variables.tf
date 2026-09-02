variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "alarm_email" {
  description = "Email address to notify on alarms. Leave empty to skip email subscription (SNS topic is still created)."
  type        = string
  default     = ""
}
