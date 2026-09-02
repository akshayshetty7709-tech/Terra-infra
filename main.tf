# ------------------------------------------------------------------------------
# Root module: wires together reusable child modules for this environment.
# ------------------------------------------------------------------------------

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "s3" {
  source = "./modules/s3"

  project_name       = var.project_name
  environment        = var.environment
  bucket_name        = var.s3_bucket_name
  versioning_enabled = var.s3_versioning_enabled
  force_destroy      = var.s3_force_destroy
}

module "cloudfront" {
  source = "./modules/cloudfront"

  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.s3.bucket_id
  s3_bucket_arn                  = module.s3.bucket_arn
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  price_class                    = var.cloudfront_price_class
}

module "eks" {
  source = "./modules/eks"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  cluster_version            = var.eks_cluster_version
  node_instance_types        = var.eks_node_instance_types
  node_desired_size          = var.eks_node_desired_size
  node_min_size              = var.eks_node_min_size
  node_max_size              = var.eks_node_max_size
  enabled_cluster_log_types  = var.eks_enabled_cluster_log_types
  cluster_log_retention_days = var.eks_cluster_log_retention_days
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  alarm_email  = var.alarm_email
}
