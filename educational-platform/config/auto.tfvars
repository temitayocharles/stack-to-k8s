# Educational Platform Infrastructure Configuration
# AWS Region and Environment
aws_region = "us-east-1"
environment = "production"

# VPC Configuration
vpc_config = {
  name = "educational-platform-vpc"
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

# EKS Cluster Configuration
eks_config = {
  name = "educational-platform-cluster"
  version = "1.28"
  endpoint_private_access = true
  endpoint_public_access = true
}

# Node Groups Configuration
node_groups = {
  general = {
    name = "general-workers"
    instance_types = ["t3.medium"]
    min_size = 2
    max_size = 10
    desired_size = 3
    capacity_type = "ON_DEMAND"
  }
  compute = {
    name = "compute-workers"
    instance_types = ["t3.large"]
    min_size = 1
    max_size = 5
    desired_size = 2
    capacity_type = "ON_DEMAND"
  }
}

# RDS Database Configuration
rds_config = {
  identifier = "educational-platform-db"
  engine = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  allocated_storage = 100
  max_allocated_storage = 1000
  db_name = "educational_platform"
  username = "edu_user"
  port = 5432
  multi_az = true
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"
  deletion_protection = true
}

# ElastiCache Redis Configuration
redis_config = {
  cluster_id = "educational-platform-redis"
  engine = "redis"
  engine_version = "7.0"
  node_type = "cache.t3.micro"
  num_cache_nodes = 1
  port = 6379
  maintenance_window = "sun:05:00-sun:06:00"
  snapshot_window = "04:00-05:00"
  snapshot_retention_limit = 7
}

# S3 Bucket Configuration
s3_config = {
  bucket_name = "educational-platform-prod-bucket"
  versioning = true
  encryption = true
  public_access_block = true
}

# CloudFront Distribution Configuration
cloudfront_config = {
  enabled = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"
  minimum_protocol_version = "TLSv1.2_2021"
}

# Route53 Configuration
route53_config = {
  domain_name = "educational-platform.com"
  create_hosted_zone = false
}

# Security Groups
security_groups = {
  alb = {
    name = "educational-platform-alb-sg"
    description = "Security group for Application Load Balancer"
  }
  eks = {
    name = "educational-platform-eks-sg"
    description = "Security group for EKS cluster"
  }
  rds = {
    name = "educational-platform-rds-sg"
    description = "Security group for RDS database"
  }
  redis = {
    name = "educational-platform-redis-sg"
    description = "Security group for Redis cluster"
  }
}

# IAM Roles and Policies
iam_config = {
  eks_service_role = {
    name = "educational-platform-eks-service-role"
    assume_role_policy = "eks-service-trust-policy"
  }
  node_group_role = {
    name = "educational-platform-node-group-role"
    assume_role_policy = "ec2-trust-policy"
  }
  alb_controller_role = {
    name = "educational-platform-alb-controller-role"
    assume_role_policy = "alb-controller-trust-policy"
  }
}

# Monitoring Configuration
monitoring_config = {
  enable_cloudtrail = true
  enable_config = true
  enable_guardduty = true
  enable_security_hub = true
  log_retention_days = 90
}

# Tags
tags = {
  Project = "Educational Platform"
  Environment = "Production"
  Owner = "DevOps Team"
  CostCenter = "Education"
  Backup = "Daily"
}
