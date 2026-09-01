variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "s3_bucket_id" {
  description = "ID (name) of the S3 bucket to use as the origin"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to use as the origin"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket origin"
  type        = string
}

variable "default_root_object" {
  description = "Object CloudFront returns for the root URL"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}
