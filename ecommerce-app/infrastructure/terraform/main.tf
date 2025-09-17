# E-commerce Platform - AWS Infrastructure with Terraform
# This creates a complete EKS cluster with all required resources

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region     = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
  
  default_tags {
    tags = {
      Project     = "E-commerce Platform"
      Environment = "production"
      ManagedBy   = "Terraform"
      Account     = var.aws.account_id
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

# VPC for EKS cluster
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster.name}-vpc"
  cidr = var.cluster.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Required for EKS
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster.name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster.name
  cluster_version = var.cluster.version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "main-nodes"

      instance_types = [var.cluster.node_type]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 4
      desired_size = var.cluster.node_count

      # Launch template configuration
      launch_template_tags = {
        Name = "${var.cluster.name}-node"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "ecommerce-platform"
  }
}

# EKS Add-ons
resource "aws_eks_addon" "addons" {
  for_each = {
    aws-ebs-csi-driver = {
      addon_version = "v1.24.1-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.4"
    }
    kube-proxy = {
      addon_version = "v1.28.2-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.15.1-eksbuild.1"
    }
  }

  cluster_name             = module.eks.cluster_name
  addon_name               = each.key
  addon_version            = each.value.addon_version
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [module.eks]
}

# Security Group for additional access
resource "aws_security_group" "additional" {
  name_prefix = "${var.project_name}-${var.environment}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-additional-sg"
  }
}

# RDS Subnet Group for MongoDB (if using RDS instead)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# ElastiCache Subnet Group for Redis
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-${var.environment}-cache-subnet"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.project_name}-${var.environment}-redis"
  description                = "Redis cache for e-commerce platform"
  
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = "default.redis7"
  
  num_cache_clusters         = var.redis_num_cache_nodes
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth_token

  tags = {
    Name = "${var.project_name}-${var.environment}-redis"
  }
}

# Security Group for Redis
resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-${var.environment}-redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# ECR Repository for backend
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}/${var.environment}/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-backend-repo"
  }
}

# ECR Repository for frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}/${var.environment}/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-frontend-repo"
  }
}

# S3 Bucket for static assets
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project_name}-${var.environment}-assets-${random_string.bucket_suffix.result}"

  tags = {
    Name = "${var.project_name}-assets"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.project_name}-${var.environment}/cluster"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-eks-logs"
  }
}
