# 🔐 SECRETS & API KEYS SETUP GUIDE
## Social Media Platform - Ruby on Rails + React Native Web

## 🚨 CRITICAL: Complete Before Starting
**Time Required: 45-60 minutes**
**Difficulty: Beginner-Friendly**

## 📋 Prerequisites Checklist
- [ ] Valid email address
- [ ] Credit/debit card (for some services)
- [ ] Web browser ready
- [ ] 45-60 minutes of uninterrupted time

## 🎯 Required Credentials
- ✅ Database URL (PostgreSQL)
- ✅ Redis URL (Caching)
- ✅ JWT Secret Key
- ✅ File Upload Service (AWS S3 or Cloudinary)
- ✅ Push Notification Service (FCM)
- ✅ Email Service (SendGrid)
- ✅ Social Login APIs (Google, Facebook, Apple)
- ✅ Content Moderation API
- ✅ Analytics Service
- ✅ CDN Configuration

## 📖 Step-by-Step Instructions

### Step 1: Database Setup (PostgreSQL)
**Time: 15 minutes**
**Difficulty: Easy**

1. **Option A - Cloud (Recommended)**:
   - Go to [Supabase](https://supabase.com) or [Neon](https://neon.tech)
   - Click "New Project"
   - Copy database URL: `postgresql://user:pass@host:port/dbname`

2. **Option B - Local**:
   ```bash
   # Using Docker
   docker run --name social-media-db -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres:15
   ```
   - Database URL: `postgresql://postgres:yourpassword@localhost:5432/social_media`

### Step 2: Redis Cache Setup
**Time: 10 minutes**
**Difficulty: Easy**

1. **Option A - Cloud**:
   - Go to [Redis Cloud](https://redis.com/redis-enterprise-cloud/)
   - Create free database
   - Copy Redis URL: `redis://user:pass@host:port`

2. **Option B - Local**:
   ```bash
   # Using Docker
   docker run --name social-media-redis -p 6379:6379 -d redis:7-alpine
   ```
   - Redis URL: `redis://localhost:6379`

### Step 3: JWT Secret Generation
**Time: 2 minutes**
**Difficulty: Easy**

```bash
# Generate secure JWT secret
openssl rand -hex 64
```
**Copy the output** and use as `JWT_SECRET`

### Step 4: File Upload Service
**Time: 20 minutes**
**Difficulty: Medium**

**Option A - AWS S3**:
1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to S3 → Create Bucket
3. Create IAM user with S3 permissions
4. Generate Access Key and Secret

**Option B - Cloudinary**:
1. Go to [Cloudinary](https://cloudinary.com)
2. Sign up for free account
3. Copy Cloud Name, API Key, API Secret from dashboard

### Step 5: Push Notifications (Firebase)
**Time: 15 minutes**
**Difficulty: Medium**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Enable Cloud Messaging
4. Download service account key JSON
5. Copy Server Key for notifications

### Step 6: Email Service (SendGrid)
**Time: 10 minutes**
**Difficulty: Easy**

1. Go to [SendGrid](https://sendgrid.com)
2. Create free account (100 emails/day)
3. Create API Key in Settings → API Keys
4. Verify sender email address

### Step 7: Social Login Setup
**Time: 30 minutes**
**Difficulty: Advanced**

**Google OAuth**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create project → Enable Google+ API
3. Create OAuth 2.0 credentials
4. Copy Client ID and Client Secret

**Facebook Login**:
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create app → Add Facebook Login
3. Copy App ID and App Secret

**Apple Sign In** (iOS only):
1. Go to [Apple Developer](https://developer.apple.com/)
2. Create App ID with Sign In capability
3. Generate private key and note Key ID

## 🧪 Testing Your Credentials

### Test Database Connection
```bash
# Test PostgreSQL
psql "postgresql://user:pass@host:port/dbname" -c "SELECT version();"

# Test Redis
redis-cli -u "redis://user:pass@host:port" ping
```

### Test File Upload
```bash
# Test with curl (adjust for your service)
curl -X POST "https://api.cloudinary.com/v1_1/your-cloud/image/upload" \
  -F "file=@test-image.jpg" \
  -F "api_key=your-api-key" \
  -F "timestamp=1234567890" \
  -F "signature=your-signature"
```

## 📝 Environment Variables Template

Create `.env` file with these variables:

```env
# Database
DATABASE_URL=postgresql://user:pass@host:port/dbname
REDIS_URL=redis://user:pass@host:port

# Security
JWT_SECRET=your-64-char-hex-string
RAILS_MASTER_KEY=your-rails-master-key

# File Storage
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Or AWS S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket-name
AWS_REGION=us-east-1

# Push Notifications
FCM_SERVER_KEY=your-fcm-server-key
FCM_PROJECT_ID=your-project-id

# Email
SENDGRID_API_KEY=SG.your-sendgrid-api-key
FROM_EMAIL=noreply@yourdomain.com

# Social Login
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
FACEBOOK_APP_ID=your-facebook-app-id
FACEBOOK_APP_SECRET=your-facebook-app-secret
APPLE_KEY_ID=your-apple-key-id
APPLE_TEAM_ID=your-apple-team-id
APPLE_PRIVATE_KEY=your-apple-private-key

# Content Moderation (Optional)
PERSPECTIVE_API_KEY=your-perspective-api-key

# Analytics (Optional)
MIXPANEL_TOKEN=your-mixpanel-token

# CDN (Optional)
CDN_URL=https://your-cdn-url.com
```

## 🆘 Troubleshooting

### Common Issues
- **"Connection refused"**: Check if database/Redis is running
- **"Invalid credentials"**: Verify API keys are copied correctly
- **"CORS errors"**: Check domain whitelist in OAuth settings
- **"Rate limits"**: Upgrade to paid plans if needed

### Recovery Steps
1. Double-check all environment variables
2. Restart services after env changes
3. Check service status dashboards
4. Verify network connectivity
5. Review API documentation for changes

## 💰 Cost Breakdown (Monthly)
- **Database**: $0-25 (Free tiers available)
- **Redis**: $0-15 (Free tiers available)
- **File Storage**: $0-10 (Free tiers available)
- **Push Notifications**: $0 (Free up to limits)
- **Email**: $0-15 (Free up to 100 emails/day)
- **Total**: $0-65/month for moderate usage

## 🚀 Next Steps
Once all credentials are configured:
1. Copy `.env.example` to `.env`
2. Fill in your actual values
3. Test database connectivity
4. Run the application: `docker-compose up`
5. Verify all services are working

---

**⚠️ Security Note**: Never commit `.env` files to version control. Keep your credentials secure and rotate them regularly.
