# This file contains all sensitive and environment-specific variables for the E-commerce platform infrastructure.
# DO NOT commit this file to version control. Add to .gitignore.

aws = {
  access_key    = "<YOUR_AWS_ACCESS_KEY>"
  secret_key    = "<YOUR_AWS_SECRET_KEY>"
  account_id    = "<YOUR_AWS_ACCOUNT_ID>"
  region        = "us-west-2"
}

cluster = {
  name          = "ecommerce-cluster"
  version       = "1.28"
  node_type     = "t3.medium"
  node_count    = 2
  vpc_cidr      = "10.0.0.0/16"
}

redis = {
  node_type     = "cache.t3.micro"
  replicas      = 1
}

ecr = {
  backend_repo  = "ecommerce/backend"
  frontend_repo = "ecommerce/frontend"
}

s3 = {
  bucket_name   = "ecommerce-assets-yourname-12345"
}

secrets = {
  jwt_secret    = "<YOUR_JWT_SECRET>"
  mongo_url     = "mongodb://mongo:27017/ecommerce"
  redis_url     = "redis://redis:6379"
}
