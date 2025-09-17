# Variables for E-commerce Platform Infrastructure

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ecommerce"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 10
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}


variable "aws" {
  description = "AWS configuration object"
  type = object({
    access_key = string
    secret_key = string
    account_id = string
    region     = string
  })
}

variable "cluster" {
  description = "EKS cluster configuration object"
  type = object({
    name       = string
    version    = string
    node_type  = string
    node_count = number
    vpc_cidr   = string
  })
}

variable "redis" {
  description = "Redis configuration object"
  type = object({
    node_type = string
    replicas  = number
  })
}

variable "ecr" {
  description = "ECR repository configuration object"
  type = object({
    backend_repo  = string
    frontend_repo = string
  })
}

variable "s3" {
  description = "S3 bucket configuration object"
  type = object({
    bucket_name = string
  })
}

variable "secrets" {
  description = "Sensitive secrets and connection strings"
  type = object({
    jwt_secret = string
    mongo_url  = string
    redis_url  = string
  })
}
