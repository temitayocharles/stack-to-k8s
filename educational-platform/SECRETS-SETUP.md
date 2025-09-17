# 🔐 Educational Platform - Secrets & API Keys Setup Guide

## 🎯 **IMPORTANT: Complete This Guide First!**

This guide will walk you through obtaining and configuring **ALL** the API keys, secrets, and credentials needed for your Educational Platform. We'll treat you like a complete beginner - every step is explained with screenshots, links, and copy-paste commands.

---

## 📋 **What You'll Get From This Guide:**

✅ **OpenAI API Key** - For AI-powered tutoring
✅ **Stripe API Keys** - For payment processing
✅ **Zoom SDK Credentials** - For video conferencing
✅ **SendGrid API Key** - For email notifications
✅ **AWS Credentials** - For cloud storage & deployment
✅ **Sentry DSN** - For error monitoring
✅ **Secure Random Keys** - For JWT and Flask secrets

---

## 🚀 **Quick Start Checklist**

- [ ] **Step 1**: OpenAI API Key (5 minutes)
- [ ] **Step 2**: Stripe API Keys (10 minutes)
- [ ] **Step 3**: Zoom Credentials (8 minutes)
- [ ] **Step 4**: SendGrid API Key (5 minutes)
- [ ] **Step 5**: AWS Credentials (15 minutes)
- [ ] **Step 6**: Sentry DSN (3 minutes)
- [ ] **Step 7**: Generate Secure Keys (2 minutes)
- [ ] **Step 8**: Test Everything (5 minutes)

---

## 🔑 **Step 1: OpenAI API Key** (For AI Tutoring)

### **What is this for?**
Your app uses AI to help students learn - answering questions, creating personalized lessons, and providing intelligent tutoring.

### **Step-by-Step Instructions:**

1. **📱 Open your web browser and go to:**
   ```
   https://platform.openai.com/
   ```

2. **👤 Create account or sign in:**
   - Click **"Sign up"** if you're new
   - Click **"Log in"** if you have an account
   - Verify your email if prompted

3. **🔑 Go to API Keys page:**
   ```
   Direct link: https://platform.openai.com/api-keys
   ```
   - Click your profile picture (top right corner)
   - Select **"API Keys"** from the menu

4. **➕ Create new API key:**
   - Click **"+ Create new secret key"** button
   - Name it: `Educational Platform`
   - Click **"Create secret key"**

5. **📋 Copy your API key:**
   - **⚠️ IMPORTANT:** Copy the key immediately!
   - You can NEVER see this key again
   - Store it safely (password manager recommended)

6. **💰 Add credits if needed:**
   ```
   Go to: https://platform.openai.com/account/billing
   ```
   - New users get **$5 free credits**
   - Add payment method if you need more

### **Copy this to your .env file:**
```bash
# Replace YOUR_ACTUAL_KEY with the key you just copied
OPENAI_API_KEY=sk-YOUR_ACTUAL_KEY_HERE
```

### **Test your key:**
```bash
# Replace YOUR_KEY with your actual key
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_KEY"
```

**✅ Expected result:** You should see a list of available models

---

## 💳 **Step 2: Stripe API Keys** (For Payments)

### **What is this for?**
Stripe handles all payments - course purchases, subscriptions, and premium features.

### **Step-by-Step Instructions:**

1. **📱 Go to Stripe website:**
   ```
   https://stripe.com/
   ```

2. **👤 Create your account:**
   - Click **"Start now"** or **"Sign Up"**
   - Fill in your business information
   - Verify email and phone number

3. **🏠 Go to your dashboard:**
   ```
   Direct link: https://dashboard.stripe.com/
   ```

4. **🔑 Get your API keys:**
   - Click **"Developers"** in left sidebar
   - Click **"API keys"** tab
   - You'll see two types of keys

5. **📋 Copy Publishable Key:**
   - Look for key starting with `pk_test_`
   - This is safe to use in your frontend code
   - Click **"Reveal test key"** and copy it

6. **📋 Copy Secret Key:**
   - Look for key starting with `sk_test_`
   - **🔴 NEVER SHARE THIS KEY**
   - Click **"Reveal test key"** and copy it
   - Store in password manager immediately

### **Copy these to your .env file:**
```bash
# Replace with your actual keys
STRIPE_PUBLIC_KEY=pk_test_YOUR_PUBLISHABLE_KEY_HERE
STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY_HERE
```

### **Test your keys:**
```bash
# Replace YOUR_SECRET_KEY with your actual secret key
curl https://api.stripe.com/v1/customers \
  -u YOUR_SECRET_KEY: \
  -d name="Test Customer"
```

**✅ Expected result:** JSON response with customer information

---

## 📹 **Step 3: Zoom SDK Credentials** (For Video Calls)

### **What is this for?**
Zoom integration allows live video classes, meetings, and student-teacher interactions.

### **Step-by-Step Instructions:**

1. **📱 Go to Zoom website:**
   ```
   https://zoom.us/
   ```

2. **👤 Create account:**
   - Click **"Sign Up, It's Free"**
   - Choose **"Basic"** or **"Free"** plan
   - Verify your email

3. **🏪 Go to Zoom Marketplace:**
   ```
   Direct link: https://marketplace.zoom.us/
   ```

4. **🔧 Access developer tools:**
   - Click **"Develop"** in top navigation
   - Click **"Build App"**

5. **📱 Create SDK app:**
   - Click **"Create"** under **"SDK"**
   - Choose **"Meeting SDK"**
   - Fill out app details:
     - **App Name:** `Educational Platform`
     - **App Type:** `Meeting SDK`
     - **Description:** `Video conferencing for online education`

6. **🔑 Get SDK credentials:**
   - After creating, go to **"App Credentials"** section
   - Copy **"SDK Key"** (this is your Client ID)
   - Copy **"SDK Secret"** (this is your Client Secret)

### **Copy these to your .env file:**
```bash
# Replace with your actual credentials
ZOOM_CLIENT_ID=YOUR_SDK_KEY_HERE
ZOOM_CLIENT_SECRET=YOUR_SDK_SECRET_HERE
```

### **Test your credentials:**
```bash
# Note: Zoom testing requires JWT token generation
# For now, just verify you have the credentials saved
echo "Zoom Client ID: $ZOOM_CLIENT_ID"
echo "Zoom Client Secret: $ZOOM_CLIENT_SECRET"
```

---

## 📧 **Step 4: SendGrid API Key** (For Emails)

### **What is this for?**
SendGrid sends all emails - password resets, course notifications, and user communications.

### **Step-by-Step Instructions:**

1. **📱 Go to SendGrid website:**
   ```
   https://sendgrid.com/
   ```

2. **👤 Create account:**
   - Click **"Try for Free"** or **"Sign Up"**
   - Choose **"Individual"** plan (free tier available)

3. **✅ Verify your account:**
   - Check email for verification link
   - Complete account setup

4. **🔑 Create API key:**
   ```
   Direct link: https://app.sendgrid.com/settings/api_keys
   ```
   - Click **"Create API Key"** button
   - **Name:** `Educational Platform`
   - **Permissions:** Select **"Full Access"**
   - Click **"Create & View"**

5. **📋 Copy API key:**
   - **⚠️ IMPORTANT:** Copy the key immediately!
   - You can NEVER see this key again
   - Store in password manager

### **Copy these to your .env file:**
```bash
# These are the exact values to use
SMTP_USERNAME=apikey
SMTP_PASSWORD=YOUR_SENDGRID_API_KEY_HERE
```

### **Test your API key:**
```bash
# Replace YOUR_SENDGRID_KEY with your actual key
curl -X POST "https://api.sendgrid.com/v3/mail/send" \
  -H "Authorization: Bearer YOUR_SENDGRID_KEY" \
  -H "Content-Type: application/json" \
  -d '{"personalizations":[{"to":[{"email":"test@example.com"}]}],"from":{"email":"test@example.com"},"subject":"Test","content":[{"type":"text/plain","value":"Hello World"}]}'
```

---

## ☁️ **Step 5: AWS Credentials** (For Cloud Services)

### **What is this for?**
AWS provides cloud storage, databases, and deployment infrastructure for your application.

### **Step-by-Step Instructions:**

1. **📱 Go to AWS website:**
   ```
   https://aws.amazon.com/
   ```

2. **👤 Create AWS account:**
   - Click **"Create an AWS Account"**
   - Fill out account information
   - Add payment method (**required**, but free tier available)
   - Verify phone number

3. **🔐 Set up IAM user:**
   ```
   Direct link: https://console.aws.amazon.com/iam/
   ```
   - Go to **"Users"** in left sidebar
   - Click **"Add users"**
   - **Username:** `educational-platform-dev`
   - Check **"Access key - Programmatic access"**

4. **🛡️ Attach permissions:**
   - Attach these managed policies:
     - ✅ `AmazonS3FullAccess`
     - ✅ `AmazonEC2FullAccess`
     - ✅ `AmazonRDSFullAccess`
     - ✅ `AmazonElastiCacheFullAccess`
     - ✅ `CloudWatchFullAccess`

5. **🔑 Create access keys:**
   - Click **"Next"** through remaining screens
   - Click **"Download .csv"** file
   - **⚠️ IMPORTANT:** This file contains your credentials!
   - Store securely - you'll need these values

6. **📋 Extract your keys:**
   - Open the downloaded CSV file
   - Copy **"Access key ID"**
   - Copy **"Secret access key"**

### **Copy these to your .env file:**
```bash
# Replace with your actual AWS credentials
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA_YOUR_ACCESS_KEY_HERE
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY_HERE
S3_BUCKET_NAME=educational-platform-dev-bucket
```

### **Test your AWS credentials:**
```bash
# Configure AWS CLI (run these commands):
aws configure
# Enter your Access Key ID when prompted
# Enter your Secret Access Key when prompted
# Enter us-east-1 for region
# Press Enter for default output format

# Test S3 access:
aws s3 ls
```

**✅ Expected result:** Empty list (you don't have buckets yet)

---

## 🐛 **Step 6: Sentry DSN** (For Error Monitoring)

### **What is this for?**
Sentry tracks application errors and performance issues in real-time.

### **Step-by-Step Instructions:**

1. **📱 Go to Sentry website:**
   ```
   https://sentry.io/
   ```

2. **👤 Create account:**
   - Click **"Get started"** or **"Sign up"**
   - Free tier available

3. **📁 Create new project:**
   ```
   Direct link: https://sentry.io/projects/
   ```
   - Click **"Create Project"**
   - **Platform:** Select `Python`
   - **Project name:** `Educational Platform`

4. **🔗 Copy DSN:**
   - After creating project, you'll see the DSN
   - It looks like: `https://abc123@sentry.io/123456`
   - Copy the entire DSN URL

### **Copy this to your .env file:**
```bash
# Replace with your actual Sentry DSN
SENTRY_DSN=https://YOUR_SENTRY_DSN_HERE@sentry.io/project-id
```

---

## 🔐 **Step 7: Generate Secure Keys** (For Local Development)

### **What are these for?**
These are secure random keys used for JWT authentication and Flask session management.

### **Generate the keys:**

```bash
# Open your terminal/command prompt and run these commands:

# Generate Flask secret key
python -c "import secrets; print('SECRET_KEY=' + secrets.token_hex(32))"

# Generate JWT secret key
python -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_urlsafe(64))"
```

### **Copy these to your .env file:**
```bash
# Replace with the keys you just generated
SECRET_KEY=YOUR_GENERATED_FLASK_SECRET_HERE
JWT_SECRET_KEY=YOUR_GENERATED_JWT_SECRET_HERE
```

---

## ✅ **Step 8: Test Everything**

### **Create your .env file:**

```bash
# In your project root directory, create a file named .env
# Copy all the values you collected above into this file

# Example .env file content:
OPENAI_API_KEY=sk-your-actual-openai-key
STRIPE_PUBLIC_KEY=pk_test_your-stripe-public-key
STRIPE_SECRET_KEY=sk_test_your-stripe-secret-key
ZOOM_CLIENT_ID=your-zoom-sdk-key
ZOOM_CLIENT_SECRET=your-zoom-sdk-secret
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA_your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
S3_BUCKET_NAME=educational-platform-dev-bucket
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
SECRET_KEY=your-generated-flask-secret
JWT_SECRET_KEY=your-generated-jwt-secret
```

### **Test your configuration:**

```bash
# Test that your .env file is properly formatted
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('✅ .env file loaded successfully!')"

# Test database connection (if you have PostgreSQL running)
python -c "import psycopg2; import os; from dotenv import load_dotenv; load_dotenv(); conn = psycopg2.connect(os.getenv('DATABASE_URL')); print('✅ Database connected!')"

# Test Redis connection (if you have Redis running)
python -c "import redis; import os; from dotenv import load_dotenv; load_dotenv(); r = redis.from_url(os.getenv('REDIS_URL')); print('✅ Redis connected!')"
```

---

## 🎉 **Congratulations! You're All Set!**

### **What you've accomplished:**
✅ **OpenAI API Key** - AI tutoring ready
✅ **Stripe API Keys** - Payments ready
✅ **Zoom Credentials** - Video calls ready
✅ **SendGrid API Key** - Emails ready
✅ **AWS Credentials** - Cloud services ready
✅ **Sentry DSN** - Error monitoring ready
✅ **Secure Keys** - Authentication ready

### **Next steps:**
1. **Start your application:** `docker-compose up -d`
2. **Visit your app:** http://localhost:8080
3. **Test features** with real API calls
4. **Deploy to production** when ready

### **Remember these security rules:**
🔴 **Never commit .env files to git**
🔴 **Never share secret keys publicly**
🔴 **Use different keys for dev/prod**
🔴 **Rotate keys regularly**

---

## 🆘 **Need Help?**

### **Common Issues:**

**❌ "API Key invalid"**
- Double-check you copied the key correctly
- Make sure there are no extra spaces
- Test with the curl commands provided

**❌ "Permission denied"**
- Make sure you're using test keys for development
- Check that your AWS user has the right permissions

**❌ "Service unavailable"**
- Check if the service has usage limits
- Verify your account is in good standing

### **Get Help:**
📧 **Email:** support@educational-platform.com
💬 **GitHub Issues:** [Report bugs](https://github.com/your-repo/issues)
📖 **Documentation:** [Full docs](./docs/)

---

**🚀 Your Educational Platform is ready to launch!**
