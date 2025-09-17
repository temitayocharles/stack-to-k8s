# 🚀 Educational Platform - Complete Setup Guide

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Set Up Your Development Environment](#step-1-set-up-your-development-environment)
3. [Step 2: Obtain All Required API Keys & Secrets](#step-2-obtain-all-required-api-keys--secrets)
4. [Step 3: Configure Your Application](#step-3-configure-your-application)
5. [Step 4: Deploy Your Application](#step-4-deploy-your-application)
6. [Troubleshooting](#troubleshooting)
7. [Security Best Practices](#security-best-practices)

---

## 📋 Prerequisites

### What You'll Need Before Starting:

#### 🖥️ **System Requirements**
- **Operating System**: macOS 10.15+, Windows 10+, or Linux
- **RAM**: At least 8GB (16GB recommended)
- **Storage**: 20GB free space
- **Internet**: Stable broadband connection

#### 🛠️ **Required Software**
```bash
# Install these tools in order:

# 1. Git (Version Control)
# Download: https://git-scm.com/downloads
git --version

# 2. Docker Desktop
# Download: https://www.docker.com/products/docker-desktop
docker --version

# 3. Node.js (Frontend Development)
# Download: https://nodejs.org/
node --version
npm --version

# 4. Python (Backend Development)
# Download: https://www.python.org/downloads/
python --version
pip --version

# 5. Visual Studio Code (Recommended Editor)
# Download: https://code.visualstudio.com/
code --version
```

#### ☁️ **Cloud Accounts You'll Need**
- **GitHub Account** (Free) - For code hosting and CI/CD
- **AWS Account** (Free tier available) - For cloud deployment
- **Stripe Account** (Free) - For payment processing
- **OpenAI Account** (Free credits) - For AI features
- **Zoom Account** (Free tier) - For video conferencing
- **SendGrid Account** (Free tier) - For email sending

---

## 🏠 Step 1: Set Up Your Development Environment

### 1.1 Clone the Repository

```bash
# Open Terminal/Command Prompt and run:
git clone https://github.com/your-username/educational-platform.git
cd educational-platform
```

### 1.2 Install Dependencies

#### Backend Dependencies
```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install Python packages
pip install -r requirements.txt
```

#### Frontend Dependencies
```bash
cd ../frontend

# Install Node.js packages
npm install
```

### 1.3 Verify Installation

```bash
# Check if everything is working
cd backend
python -c "import flask; print('Flask works!')"

cd ../frontend
npm run build
```

---

## 🔑 Step 2: Obtain All Required API Keys & Secrets

### 🎯 **Important Notes Before Starting:**

- **Save all keys securely** - Use a password manager
- **Never commit secrets** to version control
- **Use different keys** for development and production
- **Test keys first** before using in production

---

### 2.1 🔐 **OpenAI API Key** (For AI Tutoring Features)

#### Why You Need This:
The educational platform uses OpenAI's GPT models to provide intelligent tutoring, answer student questions, and generate personalized learning content.

#### Step-by-Step Guide:

1. **Go to OpenAI Website**
   ```
   🌐 Open your browser and go to: https://platform.openai.com/
   ```

2. **Create Account or Sign In**
   - Click "Sign up" if new user
   - Click "Log in" if existing user
   - Verify your email address

3. **Access API Keys Page**
   ```
   🔗 Direct link: https://platform.openai.com/api-keys
   ```
   - Click on your profile picture (top right)
   - Select "API Keys" from dropdown

4. **Create New API Key**
   - Click the "+ Create new secret key" button
   - Give it a name: `Educational Platform Dev`
   - **IMPORTANT**: Copy the key immediately (you won't see it again!)
   - Store it securely in your password manager

5. **Add Credits (If Needed)**
   ```
   💳 Billing page: https://platform.openai.com/account/billing
   ```
   - OpenAI provides $5 in free credits for new users
   - Add payment method if you need more credits

#### Copy These Values:
```bash
# Add to your .env file:
OPENAI_API_KEY=sk-your-actual-api-key-here
```

#### Test Your Key:
```bash
# Test with curl (replace YOUR_KEY with actual key):
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_KEY"
```

---

### 2.2 💳 **Stripe API Keys** (For Payment Processing)

#### Why You Need This:
Stripe handles all payment processing for course purchases, subscriptions, and premium features.

#### Step-by-Step Guide:

1. **Create Stripe Account**
   ```
   🌐 Go to: https://stripe.com/
   ```
   - Click "Start now" or "Sign up"
   - Fill out business information
   - Verify your email and phone number

2. **Access Dashboard**
   ```
   🔗 Dashboard: https://dashboard.stripe.com/
   ```
   - Log in to your Stripe account

3. **Get API Keys**
   - Click "Developers" in left sidebar
   - Click "API keys" tab
   - You'll see two types of keys:

4. **Copy Publishable Key** (Starts with `pk_test_` or `pk_live_`)
   - This is safe to use in frontend code
   - Copy the "Publishable key"

5. **Copy Secret Key** (Starts with `sk_test_` or `sk_live_`)
   - **NEVER share this key publicly**
   - Copy the "Secret key"
   - Store securely - this has full access to your Stripe account

#### Copy These Values:
```bash
# Add to your .env file:
STRIPE_PUBLIC_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
```

#### Test Your Keys:
```bash
# Test public key (safe to run):
curl https://api.stripe.com/v1/customers \
  -u sk_test_your_secret_key_here: \
  -d name="Test Customer"
```

---

### 2.3 📹 **Zoom API Credentials** (For Video Conferencing)

#### Why You Need This:
Zoom integration allows live video classes, office hours, and student-teacher meetings.

#### Step-by-Step Guide:

1. **Create Zoom Account**
   ```
   🌐 Go to: https://zoom.us/
   ```
   - Click "Sign Up, It's Free"
   - Choose account type (Basic/Free is fine for development)

2. **Verify Your Account**
   - Check email for verification link
   - Complete account setup

3. **Access Zoom App Marketplace**
   ```
   🔗 Marketplace: https://marketplace.zoom.us/
   ```
   - Click "Develop" in top navigation
   - Click "Build App"

4. **Create SDK App**
   - Click "Create" under "SDK"
   - Choose "Meeting SDK"
   - Fill out app details:
     - App Name: `Educational Platform`
     - App Type: `Meeting SDK`
     - Description: `Video conferencing for online education`

5. **Get SDK Credentials**
   - After creating app, go to "App Credentials" section
   - Copy "SDK Key" (this is your Client ID)
   - Copy "SDK Secret" (this is your Client Secret)

#### Copy These Values:
```bash
# Add to your .env file:
ZOOM_CLIENT_ID=your_sdk_key_here
ZOOM_CLIENT_SECRET=your_sdk_secret_here
```

#### Test Your Credentials:
```bash
# Test Zoom API (replace with your credentials):
curl -X POST "https://api.zoom.us/v2/users/me/meetings" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"topic":"Test Meeting","type":1}'
```

---

### 2.4 📧 **SendGrid API Key** (For Email Sending)

#### Why You Need This:
SendGrid handles all transactional emails like password resets, course notifications, and user communications.

#### Step-by-Step Guide:

1. **Create SendGrid Account**
   ```
   🌐 Go to: https://sendgrid.com/
   ```
   - Click "Try for Free" or "Sign Up"
   - Choose "Individual" plan (free tier available)

2. **Verify Your Account**
   - Check email for verification
   - Complete account setup

3. **Access API Keys**
   ```
   🔗 API Keys: https://app.sendgrid.com/settings/api_keys
   ```
   - Click "Create API Key" button
   - Give it a name: `Educational Platform`
   - Select "Full Access" permissions
   - Click "Create & View"

4. **Copy API Key**
   - **IMPORTANT**: Copy the API key immediately
   - You won't be able to see it again!
   - Store securely in password manager

#### Copy These Values:
```bash
# Add to your .env file:
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key_here
```

#### Test Your API Key:
```bash
# Test SendGrid API:
curl -X POST "https://api.sendgrid.com/v3/mail/send" \
  -H "Authorization: Bearer YOUR_SENDGRID_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"personalizations":[{"to":[{"email":"test@example.com"}]}],"from":{"email":"test@example.com"},"subject":"Test","content":[{"type":"text/plain","value":"Hello World"}]}'
```

---

### 2.5 ☁️ **AWS Credentials** (For Cloud Services)

#### Why You Need This:
AWS provides cloud storage (S3), database hosting, and deployment infrastructure.

#### Step-by-Step Guide:

1. **Create AWS Account**
   ```
   🌐 Go to: https://aws.amazon.com/
   ```
   - Click "Create an AWS Account"
   - Fill out account information
   - Add payment method (required, but free tier available)

2. **Set Up IAM User**
   ```
   🔗 IAM Console: https://console.aws.amazon.com/iam/
   ```
   - Go to "Users" in left sidebar
   - Click "Add users"
   - Username: `educational-platform-dev`
   - Select "Access key - Programmatic access"

3. **Attach Policies**
   - Attach these managed policies:
     - `AmazonS3FullAccess`
     - `AmazonEC2FullAccess`
     - `AmazonRDSFullAccess`
     - `AmazonElastiCacheFullAccess`
     - `CloudWatchFullAccess`

4. **Create Access Keys**
   - After creating user, click "Download .csv" file
   - This contains your Access Key ID and Secret Access Key
   - **Store this file securely!**

#### Copy These Values:
```bash
# Add to your .env file:
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA_your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_access_key_here
S3_BUCKET_NAME=educational-platform-dev-bucket
```

#### Test Your AWS Credentials:
```bash
# Configure AWS CLI:
aws configure

# Test S3 access:
aws s3 ls
```

---

### 2.6 🐛 **Sentry DSN** (For Error Monitoring)

#### Why You Need This:
Sentry tracks application errors and performance issues in real-time.

#### Step-by-Step Guide:

1. **Create Sentry Account**
   ```
   🌐 Go to: https://sentry.io/
   ```
   - Click "Get started" or "Sign up"
   - Choose plan (free tier available)

2. **Create New Project**
   ```
   🔗 Projects: https://sentry.io/projects/
   ```
   - Click "Create Project"
   - Select platform: `Python` (for backend)
   - Project name: `Educational Platform`

3. **Get DSN**
   - After creating project, you'll see the DSN
   - It looks like: `https://abc123@sentry.io/123456`
   - Copy the entire DSN URL

#### Copy These Values:
```bash
# Add to your .env file:
SENTRY_DSN=https://your_sentry_dsn_here@sentry.io/project-id
```

---

### 2.7 🔐 **Generate Secure Keys** (For Local Development)

#### For JWT and Flask Secrets:

```bash
# Generate a secure random key for Flask
python -c "import secrets; print(secrets.token_hex(32))"

# Generate a secure random key for JWT
python -c "import secrets; print(secrets.token_urlsafe(64))"
```

#### Copy These Values:
```bash
# Add to your .env file:
SECRET_KEY=your_generated_flask_secret_here
JWT_SECRET_KEY=your_generated_jwt_secret_here
```

---

## ⚙️ Step 3: Configure Your Application

### 3.1 Create Environment Files

#### Development Configuration:
```bash
# Copy the development template
cp config/development.env .env

# Edit with your actual values
nano .env  # or use any text editor
```

#### Production Configuration:
```bash
# Copy the production template
cp config/production.env .env.production

# Edit with your production values
nano .env.production
```

### 3.2 Database Setup

#### Local PostgreSQL (Development):
```bash
# Install PostgreSQL locally or use Docker
docker run --name postgres-edu -e POSTGRES_DB=educational_platform_dev \
  -e POSTGRES_USER=edu_user -e POSTGRES_PASSWORD=edu_password \
  -p 5432:5432 -d postgres:15

# Update your .env file:
DATABASE_URL=postgresql://edu_user:edu_password@localhost:5432/educational_platform_dev
```

#### Local Redis (Development):
```bash
# Start Redis with Docker
docker run --name redis-edu -p 6379:6379 -d redis:7-alpine

# Update your .env file:
REDIS_URL=redis://localhost:6379/0
```

### 3.3 Test Configuration

```bash
# Test backend configuration
cd backend
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('Config loaded successfully!')"

# Test database connection
python -c "import psycopg2; import os; from dotenv import load_dotenv; load_dotenv(); conn = psycopg2.connect(os.getenv('DATABASE_URL')); print('Database connected!')"

# Test Redis connection
python -c "import redis; import os; from dotenv import load_dotenv; load_dotenv(); r = redis.from_url(os.getenv('REDIS_URL')); print('Redis connected!')"
```

---

## 🚀 Step 4: Deploy Your Application

### 4.1 Local Development Deployment

```bash
# Start all services with Docker Compose
docker-compose up -d

# Check if services are running
docker-compose ps

# View logs
docker-compose logs -f
```

### 4.2 Access Your Application

```
🌐 Frontend: http://localhost:8080
🔗 Backend API: http://localhost:5000
📊 API Docs: http://localhost:5000/api/docs
```

### 4.3 Test Basic Functionality

```bash
# Test backend health
curl http://localhost:5000/api/health

# Test frontend
curl http://localhost:8080
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions:

#### 1. **"Module not found" errors**
```bash
# Reinstall dependencies
cd backend && pip install -r requirements.txt
cd ../frontend && npm install
```

#### 2. **Database connection failed**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Restart database
docker restart postgres-edu

# Check database logs
docker logs postgres-edu
```

#### 3. **Redis connection failed**
```bash
# Check if Redis is running
docker ps | grep redis

# Test Redis connection
docker exec -it redis-edu redis-cli ping
```

#### 4. **API Key authentication failed**
```bash
# Test OpenAI API key
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_OPENAI_KEY"

# Test Stripe API key
curl https://api.stripe.com/v1/customers \
  -u YOUR_STRIPE_SECRET_KEY:
```

#### 5. **Port already in use**
```bash
# Find what's using the port
lsof -i :5000  # Linux/Mac
netstat -ano | findstr :5000  # Windows

# Kill the process
kill -9 PROCESS_ID
```

---

## 🔒 Security Best Practices

### 1. **Never Commit Secrets**
```bash
# Add to .gitignore
.env
.env.local
.env.production
config/production.env
```

### 2. **Use Environment Variables**
- Always load secrets from environment variables
- Never hardcode secrets in source code
- Use different secrets for each environment

### 3. **Regular Key Rotation**
- Rotate API keys every 90 days
- Use the principle of least privilege
- Monitor key usage and revoke unused keys

### 4. **Secure Storage**
- Use password managers for key storage
- Enable 2FA on all accounts
- Store backups securely

---

## 📞 Need Help?

### Quick Support Resources:

1. **📖 Documentation**
   - [OpenAI API Docs](https://platform.openai.com/docs)
   - [Stripe API Docs](https://stripe.com/docs)
   - [Zoom SDK Docs](https://marketplace.zoom.us/docs/sdk)
   - [SendGrid API Docs](https://docs.sendgrid.com/)

2. **💬 Community Support**
   - [GitHub Issues](https://github.com/your-username/educational-platform/issues)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/educational-platform)

3. **📧 Contact**
   - Email: support@educational-platform.com
   - Discord: [Educational Platform Community](https://discord.gg/educational-platform)

---

## ✅ **You're All Set!**

🎉 **Congratulations!** You've successfully set up your Educational Platform with all required API keys and secrets. Your application is now ready for development and deployment.

### Next Steps:
1. **Start developing** your features
2. **Test the application** locally
3. **Deploy to production** when ready
4. **Monitor and maintain** your application

### Remember:
- Keep your secrets secure
- Test regularly
- Update dependencies
- Monitor your application

**Happy coding! 🚀**
