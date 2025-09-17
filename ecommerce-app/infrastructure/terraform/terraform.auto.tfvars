# AWS Configuration
aws_region = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Environment Configuration
environment = "production"
project_name = "ecommerce-app"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
database_subnet_cidrs = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

# EKS Configuration
cluster_name = "ecommerce-eks-cluster"
kubernetes_version = "1.28"
node_group_desired_size = 3
node_group_max_size = 10
node_group_min_size = 1
node_instance_types = ["t3.medium", "t3.large"]
node_disk_size = 50

# RDS Configuration
db_instance_class = "db.t3.micro"
db_allocated_storage = 20
db_max_allocated_storage = 100
db_storage_encrypted = true
db_backup_retention_period = 7
db_backup_window = "03:00-04:00"
db_maintenance_window = "sun:04:00-sun:05:00"
db_deletion_protection = true

# ElastiCache Configuration
elasticache_node_type = "cache.t3.micro"
elasticache_num_cache_nodes = 2
elasticache_port = 6379

# Application Load Balancer Configuration
enable_alb = true
alb_idle_timeout = 60
enable_deletion_protection = true

# Auto Scaling Configuration
autoscaling_min_size = 2
autoscaling_max_size = 20
autoscaling_desired_capacity = 3
target_cpu_utilization = 70

# CloudWatch Configuration
cloudwatch_log_retention_days = 14
enable_detailed_monitoring = true

# S3 Configuration
s3_bucket_versioning = true
s3_bucket_encryption = true
s3_bucket_public_access_block = true

# Security Configuration
allowed_cidr_blocks = ["0.0.0.0/0"]  # Should be restricted in production
ssl_certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# Container Image Configuration
backend_image = "ecommerce-backend:latest"
frontend_image = "ecommerce-frontend:latest"

# Feature Flags
enable_monitoring = true
enable_logging = true
enable_backup = true
enable_multi_az = true

# Cost Optimization
enable_spot_instances = false
instance_termination_protection = false

# Tags
common_tags = {
  Environment = "production"
  Project     = "ecommerce-app"
  Owner       = "devops-team"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
  Application = "ecommerce"
}

# Secrets Configuration (These should be set via environment variables or AWS Secrets Manager)
# db_username = "admin"
# db_password = "change-me-in-production"
# jwt_secret = "change-me-in-production"
# stripe_secret_key = "sk_live_change_me"
# stripe_publishable_key = "pk_live_change_me"

# Notification Configuration
notification_email = "devops@company.com"
slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

# Backup Configuration
backup_schedule = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC
backup_retention_period = 30

# Monitoring Configuration
health_check_path = "/health"
health_check_interval = 30
health_check_timeout = 5
healthy_threshold = 2
unhealthy_threshold = 3
