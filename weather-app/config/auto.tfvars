# Weather Application - Terraform Variables (Object Type)
# This file contains all configuration variables for infrastructure provisioning

# AWS Configuration
aws = {
  region     = "us-east-1"
  access_key = "your-aws-access-key-id"
  secret_key = "your-aws-secret-access-key"
  account_id = "123456789012"
}

# EKS Cluster Configuration
cluster = {
  name       = "weather-cluster"
  version    = "1.28"
  node_type  = "t3.small"
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
  backend_repo  = "weather/backend"
  frontend_repo = "weather/frontend"
}

# S3 Bucket Configuration
s3 = {
  bucket_name = "weather-prod-assets"
}

# Application Secrets
secrets = {
  db_password    = "your-secure-database-password"
  redis_password = "your-secure-redis-password"
  jwt_secret     = "your-secure-jwt-secret-key"
  api_key        = "your-openweather-api-key"
  secret_key     = "your-secure-secret-key"
}
