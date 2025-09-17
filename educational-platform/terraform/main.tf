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
  
  backend "s3" {
    bucket = "educational-platform-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "EducationalPlatform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "TCA-InfraForge"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Configuration
resource "aws_vpc" "educational_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "educational_igw" {
  vpc_id = aws_vpc.educational_vpc.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.educational_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.educational_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "educational_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version
  
  vpc_config {
    subnet_ids              = concat(aws_subnet.public_subnets[*].id, aws_subnet.private_subnets[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.allowed_cidrs
  }
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_encryption_key.arn
    }
    resources = ["secrets"]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
  
  tags = {
    Name = var.cluster_name
  }
}

# EKS Node Group
resource "aws_eks_node_group" "educational_nodes" {
  cluster_name    = aws_eks_cluster.educational_cluster.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private_subnets[*].id
  
  instance_types = var.node_instance_types
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = var.node_disk_size
  
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }
  
  update_config {
    max_unavailable = 1
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
  
  tags = {
    Name = "${var.cluster_name}-nodes"
  }
}

# RDS PostgreSQL Database
resource "aws_db_subnet_group" "educational_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id
  
  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = aws_vpc.educational_vpc.id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group_sg.id]
  }
  
  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "educational_db" {
  identifier             = "${var.project_name}-database"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  max_allocated_storage  = var.rds_max_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  kms_key_id            = aws_kms_key.rds_encryption_key.arn
  
  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.educational_db_subnet_group.name
  
  backup_retention_period = var.rds_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  deletion_protection = var.environment == "production" ? true : false
  skip_final_snapshot = var.environment == "production" ? false : true
  final_snapshot_identifier = var.environment == "production" ? "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn        = aws_iam_role.rds_monitoring_role.arn
  
  tags = {
    Name = "${var.project_name}-database"
  }
}

# S3 Bucket for Video Content
resource "aws_s3_bucket" "educational_content" {
  bucket = "${var.project_name}-content-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "${var.project_name}-content"
  }
}

resource "aws_s3_bucket_versioning" "educational_content_versioning" {
  bucket = aws_s3_bucket.educational_content.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "educational_content_encryption" {
  bucket = aws_s3_bucket.educational_content.id
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_encryption_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# CloudFront Distribution for Content Delivery
resource "aws_cloudfront_distribution" "educational_cdn" {
  origin {
    domain_name = aws_s3_bucket.educational_content.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.educational_content.id}"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.educational_oai.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.educational_content.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name = "${var.project_name}-cdn"
  }
}

resource "aws_cloudfront_origin_access_identity" "educational_oai" {
  comment = "Educational Platform OAI"
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# KMS Keys
resource "aws_kms_key" "eks_encryption_key" {
  description             = "EKS encryption key for ${var.project_name}"
  deletion_window_in_days = 7
  
  tags = {
    Name = "${var.project_name}-eks-encryption"
  }
}

resource "aws_kms_key" "rds_encryption_key" {
  description             = "RDS encryption key for ${var.project_name}"
  deletion_window_in_days = 7
  
  tags = {
    Name = "${var.project_name}-rds-encryption"
  }
}

resource "aws_kms_key" "s3_encryption_key" {
  description             = "S3 encryption key for ${var.project_name}"
  deletion_window_in_days = 7
  
  tags = {
    Name = "${var.project_name}-s3-encryption"
  }
}
