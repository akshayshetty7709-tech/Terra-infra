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

variable "ec2_instance_ids" {
  description = "EC2 instance IDs to monitor for CPU utilization"
  type        = list(string)
  default     = []
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers an alarm"
  type        = number
  default     = 80
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (from the alb module) for CloudWatch metrics. Leave empty to skip ALB alarms."
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group (from the alb module) for CloudWatch metrics. Leave empty to skip target group alarms."
  type        = string
  default     = ""
}

variable "alb_5xx_threshold" {
  description = "Number of ALB 5xx errors in a 5-minute period that triggers an alarm"
  type        = number
  default     = 10
}
