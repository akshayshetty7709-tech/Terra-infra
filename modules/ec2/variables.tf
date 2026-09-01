variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to launch instances into"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to launch instances into (one instance per subnet, cycling if fewer subnets than instances)"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to disable key-based SSH."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB. If set, HTTP ingress is restricted to the ALB instead of the open internet."
  type        = string
  default     = ""
}

variable "target_group_arn" {
  description = "ALB target group ARN to register instances with. Leave empty to skip registration."
  type        = string
  default     = ""
}
