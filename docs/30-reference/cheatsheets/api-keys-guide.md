# 🔑 API Keys & External Services Setup Guide

Where to get external API keys and how to wire them into your lab environments securely.

## Overview

This guide provides step-by-step instructions for obtaining API keys from popular services used in our Kubernetes labs.

---

## 🌦️ Weather Services

### OpenWeatherMap API
**Used in**: Weather App (Lab 1)
**Cost**: Free tier available

#### Setup Steps:
1. **Sign Up**
   - Visit: https://openweathermap.org/api
   - Click "Sign Up" → Create account
   - Verify email address

2. **Get API Key**
   - Login → Go to "API Keys" tab
   - Copy your default API key
   - **Format**: `abcd1234efgh5678ijkl9012mnop3456`

3. **Configure**
   ```bash
   # In .env file
   OPENWEATHER_API_KEY=your_api_key_here
   
   # In Kubernetes
   kubectl create secret generic weather-secrets \
     --from-literal=OPENWEATHER_API_KEY="your_api_key_here" \
     --namespace=weather
   ```
   # Verify API key works
   ```

#### Limits:
- **Free**: 1,000 calls/day, 60 calls/minute
- **Paid**: Higher limits available

---

## 💳 Payment Services

### Stripe API
**Used in**: E-commerce App (Lab 2), Educational Platform (Lab 3)
**Cost**: Transaction fees only

#### Setup Steps:
1. **Sign Up**
   - Visit: https://dashboard.stripe.com/register
   - Create account with business details
   - Verify email and phone

2. **Get Test Keys**
   - Dashboard → Developers → API Keys
   - Toggle "Test data" ON
   - Copy **Publishable Key** and **Secret Key**

3. **Configure**
   ```bash
   # Test keys (safe to expose publishable key)
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   STRIPE_SECRET_KEY=sk_test_...
   
   # Webhook secret (optional)
   STRIPE_WEBHOOK_SECRET=whsec_...
   ```

4. **Test Payment**
   ```bash
   # Use test card: 4242 4242 4242 4242
   # Any future expiry, any CVC
   ```

#### Key Types:
- **Publishable** (`pk_test_...`): Safe for frontend
- **Secret** (`sk_test_...`): Server-side only
- **Webhook** (`whsec_...`): For event verification

---

## 📧 Email Services

### SendGrid API
**Used in**: E-commerce, Educational Platform, Medical System
**Cost**: Free tier available

#### Setup Steps:
1. **Sign Up**
   - Visit: https://sendgrid.com/pricing/
   - Choose "Free" plan
   - Verify email and complete setup

2. **Create API Key**
   - Dashboard → Settings → API Keys
   - Click "Create API Key"
   - Choose "Full Access" or "Restricted"
   - Copy the key (**shown only once!**)

3. **Configure**
   ```bash
   SENDGRID_API_KEY=SG.your_api_key_here
   EMAIL_FROM=noreply@yourdomain.com
   ```

4. **Verify Domain** (Production)
   - Settings → Sender Authentication
   - Add your domain
   - Follow DNS setup instructions

#### Free Limits:
- 100 emails/day
- No daily sending limit after phone verification

---

## 🤖 AI Services

### OpenAI API
**Used in**: Educational Platform (Lab 3), Social Media (Lab 6)
**Cost**: Pay-per-use

#### Setup Steps:
1. **Sign Up**
   - Visit: https://help.openai.com/en/articles/4936850-where-do-i-find-my-openai-api-key
   - Verify phone number
   - Add billing method (required for usage)

2. **Get API Key**
   - Dashboard → API Keys
   - Click "Create new secret key"
   - Copy key (**shown only once!**)

3. **Configure**
   ```bash
   OPENAI_API_KEY=sk-proj-...your_key_here
   ```

4. **Set Usage Limits**
   - Billing → Usage limits
   - Set monthly/daily limits to control costs

#### Pricing (as of 2024):
- **GPT-3.5**: ~$0.002/1K tokens
- **GPT-4**: ~$0.03/1K tokens
- **Free credits**: $5 for new accounts

---

## ☁️ Cloud Storage

### AWS S3
**Used in**: Multiple apps for file storage
**Cost**: Free tier available

#### Setup Steps:
1. **Create AWS Account**
   - Visit: https://aws.amazon.com/
   - Sign up (requires credit card)
   - Complete verification

2. **Create IAM User**
   - IAM Console → Users → Add User
   - Username: `s3-app-user`
   - Access type: Programmatic access
   - Attach policy: `AmazonS3FullAccess`

3. **Get Credentials**
   - Download `.csv` file with:
   - Access Key ID
   - Secret Access Key

4. **Create S3 Bucket**
   ```bash
   aws s3 mb s3://your-app-bucket-name
   ```

5. **Configure**
   ```bash
   AWS_ACCESS_KEY_ID=AKIA...
   AWS_SECRET_ACCESS_KEY=your_secret...
   AWS_REGION=us-west-2
   AWS_S3_BUCKET=your-app-bucket-name
   ```

### Cloudinary (Alternative)
**Used in**: Social Media Platform
**Cost**: Free tier available

#### Setup Steps:
1. **Sign Up**
   - Visit: https://cloudinary.com/
   - Create free account

2. **Get Credentials**
   - Dashboard shows:
   - Cloud Name
   - API Key
   - API Secret

3. **Configure**
   ```bash
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```

---

## 💬 Communication Services

### Slack Webhooks
**Used in**: Task Management, Social Media
**Cost**: Free

#### Setup Steps:
1. **Create Slack App**
   - Visit: https://api.slack.com/apps
   - Click "Create New App"
   - Choose workspace

2. **Enable Webhooks**
   - Features → Incoming Webhooks
   - Toggle "On"
   - Add New Webhook to Workspace

3. **Configure**
   ```bash
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
   ```

### Discord Webhooks (Alternative)
1. **Server Settings** → Integrations → Webhooks
2. **Create Webhook** → Copy URL
3. **Configure**:
   ```bash
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
   ```

---

## 📹 Video Services

### Zoom API
**Used in**: Educational Platform
**Cost**: Free for basic features

#### Setup Steps:
1. **Zoom App Marketplace**
   - Visit: https://marketplace.zoom.us/
   - Sign in with Zoom account
   - Develop → Build App

2. **Create Server-to-Server OAuth App**
   - Choose "Server-to-Server OAuth"
   - Fill app information
   - Get credentials

3. **Configure**
   ```bash
   ZOOM_CLIENT_ID=your_client_id
   ZOOM_CLIENT_SECRET=your_client_secret
   ZOOM_ACCOUNT_ID=your_account_id
   ```

---

## 🔐 Authentication Services

### Firebase/Google
**Used in**: Social Media Platform
**Cost**: Free tier available

#### Setup Steps:
1. **Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Create new project
   - Enable Authentication

2. **Get Config**
   - Project Settings → General
   - Add app → Web
   - Copy configuration

3. **Configure**
   ```bash
   FIREBASE_API_KEY=your_api_key
   FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   FIREBASE_PROJECT_ID=your_project_id
   ```

---

## 🏃‍♂️ Quick Setup Scripts

### Generate All Secrets
```bash
#!/bin/bash
# generate-secrets.sh

echo "🔐 Generating secure secrets..."

# JWT Secret (64 bytes)
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")

# Session Secret (32 bytes)
SESSION_SECRET=$(openssl rand -base64 32)

# Database Password (16 chars)
DB_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)

echo "JWT_SECRET=${JWT_SECRET}"
echo "SESSION_SECRET=${SESSION_SECRET}"
echo "DB_PASSWORD=${DB_PASSWORD}"
echo ""
echo "💾 Add these to your .env file!"
```

### Test API Keys
```bash
#!/bin/bash
# test-apis.sh

echo "🧪 Testing API keys..."

# Test OpenWeather
if [[ -n "$OPENWEATHER_API_KEY" ]]; then
  echo "Testing OpenWeather..."
  curl -s "http://api.openweathermap.org/data/2.5/weather?q=London&appid=$OPENWEATHER_API_KEY" | jq '.name // "ERROR"'
fi

# Test Stripe
if [[ -n "$STRIPE_SECRET_KEY" ]]; then
  echo "Testing Stripe..."
  curl -s https://api.stripe.com/v1/payment_methods \
    -u "$STRIPE_SECRET_KEY:" | jq '.object // "ERROR"'
fi

# Test SendGrid
if [[ -n "$SENDGRID_API_KEY" ]]; then
  echo "Testing SendGrid..."
  curl -s -X GET "https://api.sendgrid.com/v3/user/profile" \
    -H "Authorization: Bearer $SENDGRID_API_KEY" | jq '.username // "ERROR"'
fi

echo "✅ API testing complete!"
```

---

## 🆓 Free Tier Summaries

| Service | Free Tier | Limits |
|---------|-----------|--------|
| **OpenWeather** | ✅ Yes | 1K calls/day |
| **Stripe** | ✅ Test mode | Unlimited test transactions |
| **SendGrid** | ✅ Yes | 100 emails/day |
| **OpenAI** | 💰 $5 credits | Limited time |
| **AWS S3** | ✅ 12 months | 5GB storage |
| **Cloudinary** | ✅ Yes | 25K transformations/month |
| **Slack** | ✅ Yes | 10K messages visible |
| **Firebase** | ✅ Yes | 50K reads/day |

---

## 🚨 Security Reminders

### ❌ Never Do This:
```bash
# DON'T commit to git
git add .env

# DON'T log secrets
console.log('API key:', process.env.API_KEY)

# DON'T use in URLs
fetch(`/api/data?key=${API_KEY}`)
```

### ✅ Always Do This:
```bash
# DO use environment variables
const apiKey = process.env.API_KEY

# DO validate keys exist
if (!process.env.API_KEY) {
  throw new Error('API_KEY is required')
}

# DO rotate keys regularly
# DO use different keys for dev/staging/prod
```

---

## 🔄 Environment Setup Workflow

### 1. **Development**
```bash
# Copy example files
cp .env.example .env

# Generate secrets
./scripts/generate-secrets.sh >> .env

# Get API keys manually
echo "OPENWEATHER_API_KEY=your_key" >> .env
echo "STRIPE_SECRET_KEY=sk_test_..." >> .env
```

### 2. **Staging/Production**
```bash
# Create Kubernetes secrets
kubectl create secret generic app-secrets \
  --from-env-file=.env.prod \
  --namespace=production

# Verify secrets
kubectl get secrets -n production
```

### 3. **Testing**
```bash
# Test all APIs
./scripts/test-apis.sh

# Deploy and verify
kubectl apply -f k8s/
kubectl logs -f deployment/myapp
```

---

## 📞 Support & Troubleshooting

### Common Issues:

1. **API Key Invalid**
   - Check key format and expiry
   - Verify account is active
   - Check usage limits

2. **CORS Errors**
   - Verify domain whitelist
   - Check referrer restrictions

3. **Rate Limiting**
   - Implement backoff/retry
   - Check usage dashboards
   - Upgrade plan if needed

### Getting Help:
- Check service status pages
- Review API documentation
- Contact support with specific error messages
- Join community forums/Discord

**Remember**: Start with free tiers, then upgrade as your project scales! 🚀