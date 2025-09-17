# E-commerce Application - Terraform Variables (Object Type)
# This file contains all configuration variables for infrastructure provisioning
# NEVER commit actual secrets - use placeholder values

# AWS Configuration
aws = {
  region     = "us-east-1"
  access_key = "your-aws-access-key-id"
  secret_key = "your-aws-secret-access-key"
  account_id = "123456789012"
}

# EKS Cluster Configuration
cluster = {
  name       = "ecommerce-cluster"
  version    = "1.28"
  node_type  = "t3.medium"
  node_count = 2
  vpc_cidr   = "10.0.0.0/16"
}

# Redis Configuration
redis = {
  node_type = "cache.t3.micro"
  replicas  = 1
}

# ECR Repository Configuration
ecr = {
  backend_repo  = "ecommerce/backend"
  frontend_repo = "ecommerce/frontend"
}

# S3 Bucket Configuration
s3 = {
  bucket_name = "ecommerce-prod-assets"
}

# Application Secrets (Use secure values in production)
secrets = {
  db_password     = "your-secure-database-password"
  redis_password  = "your-secure-redis-password"
  jwt_secret      = "your-secure-jwt-secret-key"
  stripe_secret   = "sk_live_your_stripe_secret_key"
  email_password  = "your-secure-email-password"
  session_secret  = "your-secure-session-secret"
  encryption_key  = "your-secure-encryption-key"
}
