variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to launch the load balancer into"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing load balancer"
  type        = list(string)
}

variable "target_port" {
  description = "Port on the EC2 targets that the load balancer forwards to"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path used for target group health checks"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Leave empty to serve HTTP only."
  type        = string
  default     = ""
}
