# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC created by the vpc module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# ------------------------------------------------------------------------------
# S3 / CloudFront
# ------------------------------------------------------------------------------

output "s3_bucket_id" {
  description = "ID (name) of the S3 bucket"
  value       = module.s3.bucket_id
}

output "cloudfront_domain_name" {
  description = "Public domain name of the CloudFront distribution"
  value       = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_id
}

# ------------------------------------------------------------------------------
# EC2 / ALB
# ------------------------------------------------------------------------------

output "ec2_instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = module.ec2.private_ips
}

output "alb_dns_name" {
  description = "Public DNS name of the load balancer - this is the URL users hit to reach the EC2-backed app"
  value       = module.alb.alb_dns_name
}

# ------------------------------------------------------------------------------
# EKS
# ------------------------------------------------------------------------------

output "eks_cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC identity provider (use as Principal in IRSA role trust policies)"
  value       = module.eks.oidc_provider_arn
}

# ------------------------------------------------------------------------------
# Monitoring
# ------------------------------------------------------------------------------

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS topic used for CloudWatch alarm notifications"
  value       = module.monitoring.sns_topic_arn
}
