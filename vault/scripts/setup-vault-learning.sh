#!/bin/bash

# 🔐 HashiCorp Vault Setup Script for Learning
# Enterprise Secret Management Practice Tool

set -e

echo "🚀 Setting up HashiCorp Vault for enterprise secret management practice..."

# Configuration - USERS SHOULD CUSTOMIZE THESE
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-vault-dev-token}"  # Change this!
VAULT_MODE="${VAULT_MODE:-development}"  # development|production

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_tip() {
    echo -e "${BLUE}[TIP]${NC} $1"
}

# Welcome message
echo "
╔════════════════════════════════════════════════════════════════╗
║  🔐 HASHICORP VAULT LEARNING ENVIRONMENT                      ║
║                                                                ║
║  This script sets up a complete Vault environment for         ║
║  practicing enterprise-grade secret management.               ║
║                                                                ║
║  📚 What you'll learn:                                        ║
║  • HashiCorp Vault deployment and configuration               ║
║  • Secret storage and retrieval best practices                ║
║  • Application integration patterns                           ║
║  • Multi-environment secret management                        ║
║  • Production-ready security policies                         ║
╚════════════════════════════════════════════════════════════════╝
"

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    print_tip "On macOS: Start Docker Desktop"
    print_tip "On Linux: sudo systemctl start docker"
    exit 1
fi

# Check if vault CLI is available (optional)
if ! command -v vault &> /dev/null; then
    print_warning "Vault CLI not found. Using docker exec instead."
    print_tip "Install Vault CLI: brew install vault (macOS) or download from https://www.vaultproject.io/downloads"
    USE_DOCKER_EXEC=true
else
    USE_DOCKER_EXEC=false
fi

# Start Vault container
print_status "Starting Vault container..."
cd "$(dirname "$0")/.."

if [ ! -f docker-compose.yml ]; then
    print_error "docker-compose.yml not found. Are you in the vault directory?"
    exit 1
fi

# Update docker-compose with user's token
if [ "$VAULT_TOKEN" != "vault-dev-token" ]; then
    print_status "Using custom token: $VAULT_TOKEN"
    export VAULT_DEV_ROOT_TOKEN_ID="$VAULT_TOKEN"
fi

docker-compose up -d

# Wait for Vault to be ready
print_status "Waiting for Vault to be ready..."
sleep 10

# Check if Vault is accessible
print_status "Testing Vault connectivity..."
attempts=0
max_attempts=30

until curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ $attempts -ge $max_attempts ]; then
        print_error "Vault failed to start after $max_attempts attempts"
        print_tip "Check logs: docker-compose logs vault"
        exit 1
    fi
    print_status "Waiting for Vault... (attempt $attempts/$max_attempts)"
    sleep 5
done

print_status "✅ Vault is ready and accessible!"

# Set up Vault CLI or docker exec function
export VAULT_ADDR="$VAULT_ADDR"
export VAULT_TOKEN="$VAULT_TOKEN"

if [ "$USE_DOCKER_EXEC" = true ]; then
    vault_cmd() {
        docker-compose exec -e VAULT_TOKEN="$VAULT_TOKEN" -e VAULT_ADDR="$VAULT_ADDR" vault vault "$@"
    }
else
    vault_cmd() {
        vault "$@"
    }
fi

# Enable KV secrets engine
print_status "Enabling KV secrets engine..."
vault_cmd secrets enable -path=secret kv-v2 2>/dev/null || print_warning "KV secrets engine may already be enabled"

# Function to generate secure random passwords
generate_password() {
    if command -v openssl &> /dev/null; then
        openssl rand -base64 32 | tr -d '\n'
    else
        # Fallback if openssl is not available
        date +%s | sha256sum | base64 | head -c 32
    fi
}

generate_api_key() {
    if command -v openssl &> /dev/null; then
        openssl rand -hex 32
    else
        date +%s | sha256sum | head -c 32
    fi
}

# Ask user what they want to set up
echo "
📝 What would you like to set up in Vault?

1) 🏪 E-commerce Application (Stripe, PayPal, Database)
2) 🎓 Educational Platform (Zoom SDK, Video conferencing)  
3) 🌤️  Weather Application (OpenWeather API, Redis)
4) 🏥 Medical Care System (Healthcare APIs, Compliance)
5) 📋 Task Management (Collaboration tools, Notifications)
6) 📱 Social Media Platform (Social APIs, Media storage)
7) 🎯 All Applications (Complete setup)
8) 🔧 Custom Setup (Manual secret entry)
"

read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        apps=("ecommerce")
        ;;
    2)
        apps=("educational")
        ;;
    3)
        apps=("weather")
        ;;
    4)
        apps=("medical")
        ;;
    5)
        apps=("task-management")
        ;;
    6)
        apps=("social-media")
        ;;
    7)
        apps=("ecommerce" "educational" "weather" "medical" "task-management" "social-media")
        ;;
    8)
        print_status "Manual setup selected. You can add secrets using:"
        print_tip "vault kv put secret/myapp/config key=value"
        print_tip "Or visit the Web UI at: $VAULT_ADDR"
        exit 0
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Ask for environments
echo "
🌍 Which environments do you want to configure?

1) Development only
2) Development + Staging  
3) Development + Staging + Production
4) Custom environments
"

read -p "Enter your choice (1-4): " env_choice

case $env_choice in
    1)
        environments=("development")
        ;;
    2)
        environments=("development" "staging")
        ;;
    3)
        environments=("development" "staging" "production")
        ;;
    4)
        read -p "Enter environments (space-separated): " custom_envs
        IFS=' ' read -ra environments <<< "$custom_envs"
        ;;
    *)
        print_error "Invalid choice. Using development only."
        environments=("development")
        ;;
esac

# Create secrets for selected applications and environments
print_status "Creating secrets for applications: ${apps[*]}"
print_status "Creating secrets for environments: ${environments[*]}"

for app in "${apps[@]}"; do
    for env in "${environments[@]}"; do
        print_status "🔧 Setting up secrets for $app/$env..."
        
        # Base application secrets
        vault_cmd kv put secret/applications/$app/$env/database \
            username="${app}_user" \
            password="$(generate_password)" \
            host="localhost" \
            port="5432" \
            database="${app}_${env}" 2>/dev/null || true
        
        vault_cmd kv put secret/applications/$app/$env/redis \
            url="redis://localhost:6379" \
            password="$(generate_password)" 2>/dev/null || true
        
        vault_cmd kv put secret/applications/$app/$env/jwt \
            secret="$(generate_password)" \
            expiry="24h" 2>/dev/null || true
        
        vault_cmd kv put secret/applications/$app/$env/session \
            secret="$(generate_password)" \
            max_age="86400" 2>/dev/null || true
        
        # Application-specific secrets
        case $app in
            "ecommerce")
                vault_cmd kv put secret/applications/$app/$env/stripe \
                    secret_key="sk_test_$(generate_api_key)" \
                    publishable_key="pk_test_$(generate_api_key)" \
                    webhook_secret="whsec_$(generate_api_key)" 2>/dev/null || true
                
                vault_cmd kv put secret/applications/$app/$env/paypal \
                    client_id="paypal_$(generate_api_key)" \
                    client_secret="$(generate_password)" 2>/dev/null || true
                ;;
                
            "educational")
                vault_cmd kv put secret/applications/$app/$env/zoom \
                    api_key="zoom_$(generate_api_key)" \
                    api_secret="$(generate_password)" \
                    sdk_key="zoom_sdk_$(generate_api_key)" \
                    sdk_secret="$(generate_password)" 2>/dev/null || true
                ;;
                
            "weather")
                vault_cmd kv put secret/applications/$app/$env/openweather \
                    api_key="$(generate_api_key)" \
                    units="metric" 2>/dev/null || true
                ;;
                
            "medical")
                vault_cmd kv put secret/applications/$app/$env/hipaa \
                    encryption_key="$(generate_password)" \
                    audit_key="$(generate_password)" 2>/dev/null || true
                ;;
                
            "task-management")
                vault_cmd kv put secret/applications/$app/$env/collaboration \
                    slack_webhook="https://hooks.slack.com/services/T00000000/B00000000/$(generate_api_key)" \
                    teams_webhook="https://outlook.office.com/webhook/$(generate_api_key)" 2>/dev/null || true
                ;;
                
            "social-media")
                vault_cmd kv put secret/applications/$app/$env/social \
                    twitter_api_key="twitter_$(generate_api_key)" \
                    facebook_app_id="fb_$(generate_api_key)" \
                    instagram_token="ig_$(generate_api_key)" 2>/dev/null || true
                ;;
        esac
        
        # Common external services for all apps
        vault_cmd kv put secret/applications/$app/$env/email \
            sendgrid_api_key="SG.$(generate_api_key)" \
            smtp_host="smtp.sendgrid.net" \
            smtp_port="587" 2>/dev/null || true
        
        vault_cmd kv put secret/applications/$app/$env/monitoring \
            sentry_dsn="https://$(generate_api_key)@sentry.io/1234567" \
            datadog_api_key="$(generate_api_key)" 2>/dev/null || true
        
        if [ "$env" = "production" ]; then
            vault_cmd kv put secret/applications/$app/$env/cloud \
                aws_access_key_id="AKIA$(generate_api_key | head -c 16)" \
                aws_secret_access_key="$(generate_password)" \
                region="us-west-2" 2>/dev/null || true
        fi
    done
done

# Create summary
print_status "📊 Generating setup summary..."

cat > vault-setup-summary.md << EOF
# 🔐 Vault Setup Summary
**Generated**: $(date)

## 🎯 Configuration
- **Vault URL**: \`$VAULT_ADDR\`
- **Root Token**: \`$VAULT_TOKEN\`
- **Mode**: $VAULT_MODE

## 📱 Applications Configured
$(printf '- ✅ %s\n' "${apps[@]}")

## 🌍 Environments Configured  
$(printf '- 🌐 %s\n' "${environments[@]}")

## 🔑 Secret Structure
\`\`\`
secret/applications/
$(for app in "${apps[@]}"; do
    for env in "${environments[@]}"; do
        echo "├── $app/"
        echo "│   └── $env/"
        echo "│       ├── database/"
        echo "│       ├── redis/"
        echo "│       ├── jwt/"
        echo "│       ├── session/"
        echo "│       ├── email/"
        echo "│       └── monitoring/"
    done
done)
\`\`\`

## 🚀 Quick Access
### Web UI
Open: [$VAULT_ADDR]($VAULT_ADDR)
Token: \`$VAULT_TOKEN\`

### CLI Commands
\`\`\`bash
# Set environment
export VAULT_ADDR="$VAULT_ADDR"
export VAULT_TOKEN="$VAULT_TOKEN"

# List all secrets
vault kv list secret/applications/

# Get a specific secret
vault kv get secret/applications/ecommerce/development/database

# Add new secret
vault kv put secret/myapp/config api_key=your-key-here
\`\`\`

## 🎓 Next Steps
1. **Explore Web UI**: Browse secrets at $VAULT_ADDR
2. **Practice CLI**: Try the commands above
3. **Integrate Apps**: Use secrets in your applications
4. **Security Policies**: Create custom access rules
5. **Production Setup**: Configure for real environments

## 📚 Learning Resources
- [Vault Documentation](https://www.vaultproject.io/docs)
- [Secret Engines](https://www.vaultproject.io/docs/secrets)
- [Authentication](https://www.vaultproject.io/docs/auth)
- [Best Practices](https://learn.hashicorp.com/vault)

---
**⚠️ Security Note**: This setup uses development mode. For production:
- Use proper storage backend (Consul, PostgreSQL)
- Enable TLS/HTTPS
- Implement proper authentication
- Regular secret rotation
- Audit logging
EOF

print_status "✅ Vault setup completed successfully!"
echo "
╔════════════════════════════════════════════════════════════════╗
║  🎉 SUCCESS! Your Vault learning environment is ready!        ║
║                                                                ║
║  🌐 Vault UI: $VAULT_ADDR                            ║
║  🔑 Token: $VAULT_TOKEN                                       ║
║  📖 Summary: vault-setup-summary.md                          ║
║                                                                ║
║  💡 Start exploring:                                          ║
║  1. Open the Web UI in your browser                           ║
║  2. Try CLI commands from the summary                         ║
║  3. Integrate with your applications                          ║
╚════════════════════════════════════════════════════════════════╝
"

print_tip "Summary saved to: vault-setup-summary.md"
print_tip "View logs: docker-compose logs vault"
print_tip "Stop Vault: docker-compose down"
print_status "🎓 Happy learning with HashiCorp Vault!"