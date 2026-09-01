project_name = "my-terraform-project"
environment  = "prod"
aws_region   = "us-east-1"

# VPC
vpc_cidr              = "10.2.0.0/16"
public_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs  = ["10.2.101.0/24", "10.2.102.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]

# S3 / CloudFront
s3_bucket_name          = "my-terraform-project-prod-assets"
s3_versioning_enabled   = true
s3_force_destroy        = false
cloudfront_price_class  = "PriceClass_All"

# EC2
ec2_instance_count    = 3
ec2_instance_type     = "t3.medium"
ec2_key_name          = ""
ec2_allowed_ssh_cidrs = []

# EKS
eks_cluster_version     = "1.30"
eks_node_instance_types = ["m5.large"]
eks_node_desired_size   = 3
eks_node_min_size       = 3
eks_node_max_size       = 6

# ALB
alb_health_check_path = "/health"
alb_certificate_arn   = ""

# Monitoring
alarm_email          = "platform-team@example.com"
cpu_alarm_threshold  = 70
alb_5xx_threshold    = 25

# EKS logging
eks_enabled_cluster_log_types  = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
eks_cluster_log_retention_days = 90
