#!/bin/bash

# 🧹 Public Application Independence Validator
# Ensures public applications don't depend on private Vault/configs

set -e

echo "🔍 Validating public application independence..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check each application
applications=("ecommerce-app" "educational-platform" "weather-app" "medical-care-system" "task-management-app" "social-media-platform")

for app in "${applications[@]}"; do
    echo -e "\n📦 Checking $app..."
    
    app_dir="/Volumes/512-B/Documents/PERSONAL/full-stack-apps/$app"
    
    if [ ! -d "$app_dir" ]; then
        print_warning "Directory $app_dir not found, skipping..."
        continue
    fi
    
    cd "$app_dir"
    
    # Check for .env.example
    if [ -f ".env.example" ]; then
        print_success ".env.example exists"
    else
        print_error ".env.example missing - public users need this!"
        # Create a basic .env.example
        cat > .env.example << EOF
# Environment Configuration Example
# Copy this file to .env and update with your values

NODE_ENV=development
PORT=3000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=${app}_development
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# Redis
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=your_redis_password

# JWT
JWT_SECRET=your_jwt_secret_here
SESSION_SECRET=your_session_secret_here

# Add other environment variables as needed
EOF
        print_success "Created .env.example template"
    fi
    
    # Check docker-compose.yml for Vault dependencies
    if [ -f "docker-compose.yml" ]; then
        if grep -q "vault" docker-compose.yml; then
            print_error "docker-compose.yml references Vault - this should be removed for public use"
        else
            print_success "docker-compose.yml is clean (no Vault dependencies)"
        fi
        
        # Check if it uses .env file
        if grep -q "env_file" docker-compose.yml || grep -q "\${" docker-compose.yml; then
            print_success "docker-compose.yml uses environment variables"
        else
            print_warning "docker-compose.yml should use environment variables"
        fi
    else
        print_warning "No docker-compose.yml found"
    fi
    
    # Check for hardcoded secrets
    secret_patterns=("sk_live_" "sk_test_" "AKIA" "rk_live_" "rk_test_")
    found_secrets=false
    
    for pattern in "${secret_patterns[@]}"; do
        if grep -r "$pattern" . --exclude-dir=node_modules --exclude-dir=.git >/dev/null 2>&1; then
            print_error "Found potential hardcoded secret pattern: $pattern"
            found_secrets=true
        fi
    done
    
    if [ "$found_secrets" = false ]; then
        print_success "No hardcoded secrets detected"
    fi
    
    # Check for Vault references in code
    if grep -r "VAULT_" . --exclude-dir=node_modules --exclude-dir=.git >/dev/null 2>&1; then
        print_error "Found Vault references in code - should be optional/configurable"
    else
        print_success "No Vault references in application code"
    fi
done

echo -e "\n🎯 Public Application Independence Summary:"
echo "✅ Applications should work with standard .env files"
echo "✅ No hardcoded secrets or Vault dependencies"
echo "✅ Public users can deploy without your private setup"
echo "✅ Your private Vault/configs are separate"

echo -e "\n📋 For public users, provide:"
echo "  - .env.example files"
echo "  - Configuration documentation"
echo "  - Standard deployment instructions"
echo "  - No dependency on your private infrastructure"