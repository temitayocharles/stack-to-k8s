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
  }
  
  backend "s3" {
    bucket = "task-management-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "TaskManagementApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "TCA-InfraForge"
    }
  }
}

# VPC Configuration
resource "aws_vpc" "task_management_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "task_management_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version
  
  vpc_config {
    subnet_ids = concat(aws_subnet.public_subnets[*].id, aws_subnet.private_subnets[*].id)
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
  
  tags = {
    Name = var.cluster_name
  }
}

# CouchDB Instance
resource "aws_instance" "couchdb" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.couchdb_instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.couchdb_sg.id]
  subnet_id             = aws_subnet.private_subnets[0].id
  
  user_data = base64encode(templatefile("${path.module}/user-data/couchdb-setup.sh", {
    couchdb_user     = var.couchdb_user
    couchdb_password = var.couchdb_password
  }))
  
  tags = {
    Name = "${var.project_name}-couchdb"
  }
}

# Security Groups
resource "aws_security_group" "couchdb_sg" {
  name_prefix = "${var.project_name}-couchdb-"
  vpc_id      = aws_vpc.task_management_vpc.id
  
  ingress {
    from_port       = 5984
    to_port         = 5984
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group_sg.id]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-couchdb-sg"
  }
}
