# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "my-terraform-project"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ------------------------------------------------------------------------------
# S3
# ------------------------------------------------------------------------------

variable "s3_bucket_name" {
  description = "Globally-unique S3 bucket name. Leave empty to auto-generate from project/environment."
  type        = string
  default     = ""
}

variable "s3_versioning_enabled" {
  description = "Whether to enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Allow the S3 bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# CloudFront
# ------------------------------------------------------------------------------

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

# ------------------------------------------------------------------------------
# EC2
# ------------------------------------------------------------------------------

variable "ec2_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to disable key-based SSH."
  type        = string
  default     = ""
}

variable "ec2_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2 instances"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# EKS
# ------------------------------------------------------------------------------

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "eks_enabled_cluster_log_types" {
  description = "EKS control plane log types to send to CloudWatch Logs"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_cluster_log_retention_days" {
  description = "Retention period (days) for EKS control plane CloudWatch log group"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# ALB
# ------------------------------------------------------------------------------

variable "alb_health_check_path" {
  description = "Path used by the ALB target group health check"
  type        = string
  default     = "/"
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener. Leave empty to serve HTTP only."
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# Monitoring
# ------------------------------------------------------------------------------

variable "alarm_email" {
  description = "Email address to receive CloudWatch alarm notifications. Leave empty to skip the email subscription."
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  description = "EC2 CPU utilization percentage that triggers an alarm"
  type        = number
  default     = 80
}

variable "alb_5xx_threshold" {
  description = "Number of ALB 5xx errors in a 5-minute period that triggers an alarm"
  type        = number
  default     = 10
}
