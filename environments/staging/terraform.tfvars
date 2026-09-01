project_name = "my-terraform-project"
environment  = "staging"
aws_region   = "us-east-1"

# VPC
vpc_cidr              = "10.1.0.0/16"
public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]

# S3 / CloudFront
s3_bucket_name          = "my-terraform-project-staging-assets"
s3_versioning_enabled   = true
s3_force_destroy        = false
cloudfront_price_class  = "PriceClass_100"

# EC2
ec2_instance_count    = 2
ec2_instance_type     = "t3.small"
ec2_key_name          = ""
ec2_allowed_ssh_cidrs = []

# EKS
eks_cluster_version     = "1.30"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 2
eks_node_max_size       = 4

# ALB
alb_health_check_path = "/"
alb_certificate_arn   = ""

# Monitoring
alarm_email          = ""
cpu_alarm_threshold  = 75
alb_5xx_threshold    = 10

# EKS logging
eks_enabled_cluster_log_types  = ["api", "audit", "authenticator"]
eks_cluster_log_retention_days = 30
