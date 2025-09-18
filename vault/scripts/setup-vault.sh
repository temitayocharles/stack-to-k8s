#!/bin/bash

# 🔐 Personal Vault Setup Script
# FOR PRIVATE DEVELOPMENT USE ONLY

set -e

echo "🚀 Setting up personal Vault for development..."

# Configuration
VAULT_ADDR="http://localhost:8200"
VAULT_TOKEN="dev-root-token-for-local-only"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start Vault container
print_status "Starting personal Vault container..."
cd "$(dirname "$0")/.."
docker-compose up -d

# Wait for Vault to be ready
print_status "Waiting for Vault to be ready..."
sleep 10

# Check if Vault is accessible
until curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; do
    print_status "Waiting for Vault to be accessible..."
    sleep 5
done

print_status "Vault is ready!"

# Set up Vault CLI
export VAULT_ADDR="$VAULT_ADDR"
export VAULT_TOKEN="$VAULT_TOKEN"

# Enable KV secrets engine
print_status "Enabling KV secrets engine..."
vault secrets enable -path=secret kv-v2 2>/dev/null || print_warning "KV secrets engine may already be enabled"

# Create application secret paths
print_status "Creating application secret structure..."

applications=("ecommerce" "educational" "weather" "medical" "task-management" "social-media")
environments=("development" "staging" "production")

for app in "${applications[@]}"; do
    for env in "${environments[@]}"; do
        print_status "Setting up secrets for $app/$env..."
        
        # Create base application secrets
        vault kv put secret/applications/$app/$env/database \
            username="${app}_user" \
            password="$(openssl rand -base64 32)" \
            host="localhost" \
            port="5432" \
            database="${app}_${env}" 2>/dev/null || true
        
        vault kv put secret/applications/$app/$env/redis \
            url="redis://localhost:6379" \
            password="$(openssl rand -base64 24)" 2>/dev/null || true
        
        vault kv put secret/applications/$app/$env/jwt \
            secret="$(openssl rand -base64 64)" 2>/dev/null || true
        
        vault kv put secret/applications/$app/$env/session \
            secret="$(openssl rand -base64 32)" 2>/dev/null || true
        
        vault kv put secret/applications/$app/$env/encryption \
            key="$(openssl rand -base64 32)" 2>/dev/null || true
    done
done

# Application-specific secrets
print_status "Creating application-specific secrets..."

# E-commerce specific
vault kv put secret/applications/ecommerce/development/stripe \
    secret_key="sk_test_$(openssl rand -hex 24)" \
    publishable_key="pk_test_$(openssl rand -hex 24)" \
    webhook_secret="whsec_$(openssl rand -hex 16)" 2>/dev/null || true

vault kv put secret/applications/ecommerce/development/paypal \
    client_id="paypal_client_$(openssl rand -hex 16)" \
    client_secret="paypal_secret_$(openssl rand -hex 32)" 2>/dev/null || true

# Educational platform specific
vault kv put secret/applications/educational/development/zoom \
    api_key="zoom_api_$(openssl rand -hex 16)" \
    api_secret="zoom_secret_$(openssl rand -hex 32)" \
    sdk_key="zoom_sdk_$(openssl rand -hex 16)" \
    sdk_secret="zoom_sdk_secret_$(openssl rand -hex 32)" 2>/dev/null || true

# Weather app specific
vault kv put secret/applications/weather/development/openweather \
    api_key="openweather_$(openssl rand -hex 32)" 2>/dev/null || true

# Common external services
for app in "${applications[@]}"; do
    vault kv put secret/applications/$app/development/sendgrid \
        api_key="SG.$(openssl rand -base64 32)" 2>/dev/null || true
    
    vault kv put secret/applications/$app/development/aws \
        access_key_id="AKIA$(openssl rand -hex 8)" \
        secret_access_key="$(openssl rand -base64 40)" 2>/dev/null || true
    
    vault kv put secret/applications/$app/development/sentry \
        dsn="https://$(openssl rand -hex 32)@sentry.io/1234567" 2>/dev/null || true
    
    vault kv put secret/applications/$app/development/datadog \
        api_key="$(openssl rand -hex 32)" 2>/dev/null || true
done

print_status "Vault setup completed successfully!"
print_status "Vault URL: $VAULT_ADDR"
print_status "Root Token: $VAULT_TOKEN"
print_warning "This is for DEVELOPMENT ONLY - not for production use!"

# Create a summary file
cat > vault-secrets-summary.txt << EOF
# Personal Vault Setup Summary
# Generated: $(date)

Vault URL: $VAULT_ADDR
Root Token: $VAULT_TOKEN

Applications configured:
$(printf '%s\n' "${applications[@]}")

Environments configured:
$(printf '%s\n' "${environments[@]}")

Secret paths created:
- secret/applications/{app}/{env}/database/
- secret/applications/{app}/{env}/redis/
- secret/applications/{app}/{env}/jwt/
- secret/applications/{app}/{env}/session/
- secret/applications/{app}/{env}/encryption/
- secret/applications/{app}/{env}/sendgrid/
- secret/applications/{app}/{env}/aws/
- secret/applications/{app}/{env}/sentry/
- secret/applications/{app}/{env}/datadog/

Application-specific secrets:
- E-commerce: Stripe, PayPal
- Educational: Zoom SDK
- Weather: OpenWeather API
- All apps: SendGrid, AWS, Sentry, DataDog

⚠️  FOR PRIVATE DEVELOPMENT USE ONLY ⚠️
EOF

print_status "Summary saved to vault-secrets-summary.txt"
print_status "🎉 Personal Vault is ready for development!"