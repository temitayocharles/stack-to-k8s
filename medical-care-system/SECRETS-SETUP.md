# 🔐 SECRETS & API KEYS SETUP GUIDE - MEDICAL CARE SYSTEM

## 🚨 CRITICAL: Complete Before Starting
**Time Required: 45-60 minutes**
**Difficulty: Beginner-Friendly**

## 📋 Prerequisites Checklist

- [ ] Valid email address
- [ ] Web browser ready
- [ ] 45-60 minutes of uninterrupted time
- [ ] Basic understanding of copying/pasting text
- [ ] Access to create accounts on external services

## 🎯 Required Credentials for Medical Care System

- ✅ SQL Server Connection String (database access)
- ✅ JWT Secret Key (user authentication)
- ✅ SendGrid API Key (email notifications)
- ✅ Stripe API Keys (payment processing for medical services)
- ✅ AWS Credentials (cloud deployment)
- ✅ Sentry DSN (error monitoring)
- ✅ Healthcare API Keys (if using external health services)

## 📖 Step-by-Step Instructions

### Step 1: SQL Server Setup
**Time: 10 minutes**
**Difficulty: Easy**

#### Option A: Local SQL Server (Free)

1. **Download SQL Server**: Visit [Microsoft SQL Server Downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
2. **You will see**: Download options page
3. **Next**: Click "Download now" for SQL Server 2022 Express
4. **Next**: Run the installer
5. **Next**: Choose "Basic" installation
6. **Next**: Accept license terms
7. **Next**: Install to default location
8. **Next**: Wait for installation to complete
9. **Next**: Open SQL Server Management Studio
10. **Create Database**: Right-click Databases → New Database → Name: "MedicalCareDB"
11. **Copy this connection string**:

```sql
Server=localhost;Database=MedicalCareDB;Trusted_Connection=True;TrustServerCertificate=True;
```

#### Option B: Azure SQL Database (Cloud)

1. **Click here**: [Azure Portal](https://portal.azure.com/)
2. **You will see**: Microsoft Azure login page
3. **Next**: Sign in with your Microsoft account
4. **Next**: Search for "SQL databases" in the search bar
5. **Next**: Click "Create SQL Database"
6. **Next**: Fill in:
   - Subscription: Your subscription
   - Resource group: Create new or select existing
   - Database name: MedicalCareDB
   - Server: Create new server
7. **Next**: Configure server settings
8. **Next**: Set admin credentials (save these!)
9. **Next**: Review and create
10. **Copy this connection string**:

```sql
Server=tcp:your-server.database.windows.net,1433;Initial Catalog=MedicalCareDB;Persist Security Info=False;User ID=your-admin;Password=your-password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

**If you get stuck**: Ensure you have administrator privileges for local installation

### Step 2: JWT Secret Key Generation
**Time: 5 minutes**
**Difficulty: Easy**

1. **Open Command Prompt/Terminal**
2. **Copy this command and paste**:

   ```bash
   openssl rand -base64 32
   ```

3. **You will see**: A random string like `abcdefghijklmnop...`
4. **Copy this value** - this is your JWT secret
5. **Save it securely** - you'll need it for your `.env` file

**Alternative**: Use [Online JWT Key Generator](https://www.uuidgenerator.net/) if OpenSSL is not available

### Step 3: SendGrid API Key (Email Notifications)
**Time: 15 minutes**
**Difficulty: Medium**

1. **Click here**: [SendGrid Signup](https://signup.sendgrid.com/)
2. **You will see**: Account creation page
3. **Next**: Fill in your details (name, email, password)
4. **Next**: Verify your email (check spam folder)
5. **Next**: Login to SendGrid dashboard
6. **Next**: Go to "Settings" → "API Keys"
7. **Next**: Click "Create API Key"
8. **Next**: Name it "MedicalCare-Email"
9. **Next**: Select "Full Access" permissions
10. **Next**: Click "Create & View"
11. **Copy this key** - it starts with `SG.`
12. **Save it securely**

**If you get stuck**: SendGrid requires email verification - check all email folders

### Step 4: Stripe API Keys (Payment Processing)
**Time: 15 minutes**
**Difficulty: Medium**

1. **Click here**: [Stripe Signup](https://dashboard.stripe.com/register)
2. **You will see**: Account registration page
3. **Next**: Fill in business details
4. **Next**: Verify email and phone
5. **Next**: Complete account setup
6. **Next**: Go to "Developers" → "API keys"
7. **You will see**: Publishable key and Secret key
8. **Copy both keys**:
   - Publishable key: `pk_test_...` or `pk_live_...`
   - Secret key: `sk_test_...` or `sk_live_...`
9. **Save them securely**

**Note**: Use test keys for development, live keys for production

### Step 5: AWS Credentials
**Time: 20 minutes**
**Difficulty: Medium**

1. **Click here**: [AWS Console](https://console.aws.amazon.com/)
2. **You will see**: AWS login page
3. **Next**: Sign in or create account
4. **Next**: Go to "IAM" service
5. **Next**: Click "Users" → "Create user"
6. **Next**: User name: "medicalcare-user"
7. **Next**: Select "Programmatic access"
8. **Next**: Attach policies: AmazonEC2FullAccess, AmazonRDSFullAccess, etc.
9. **Next**: Create user
10. **Download CSV** with Access Key ID and Secret Access Key
11. **Copy these values**:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - AWS_DEFAULT_REGION (e.g., us-east-1)

**If you get stuck**: AWS requires credit card verification for new accounts

### Step 6: Sentry DSN (Error Monitoring)
**Time: 10 minutes**
**Difficulty: Easy**

1. **Click here**: [Sentry Signup](https://sentry.io/signup/)
2. **You will see**: Account creation page
3. **Next**: Fill in details and create account
4. **Next**: Create new project
5. **Next**: Select ".NET Core" as platform
6. **Next**: Name: "Medical Care System"
7. **Next**: Copy the DSN from the setup instructions
8. **DSN looks like**: `https://abc123@sentry.io/1234567`

## 🧪 Testing Your Credentials

### Test SQL Server Connection

```bash
# For local SQL Server
sqlcmd -S localhost -d MedicalCareDB -Q "SELECT @@VERSION"
```

**Expected Result**: SQL Server version information

### Test SendGrid API Key

```bash
curl -X POST https://api.sendgrid.com/v1/mail/send \
  -H "Authorization: Bearer YOUR_SENDGRID_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"personalizations":[{"to":[{"email":"test@example.com"}]}],"from":{"email":"noreply@medicalcare.com"},"subject":"Test","content":[{"type":"text/plain","value":"Test email"}]}'
```

**Expected Result**: 202 Accepted response

### Test Stripe API Key

```bash
curl https://api.stripe.com/v1/customers \
  -u YOUR_STRIPE_SECRET_KEY:
```

**Expected Result**: JSON list of customers (empty if new account)

## 🆘 Troubleshooting

### Common Issues:

#### "SQL Server connection failed"
- **Local**: Ensure SQL Server service is running
- **Azure**: Check firewall settings allow your IP
- **Solution**: Update connection string with correct credentials

#### "SendGrid API key invalid"
- Check you copied the entire key (starts with SG.)
- Ensure key has correct permissions
- **Solution**: Regenerate API key in SendGrid dashboard

#### "Stripe test mode not working"
- Use test keys, not live keys for development
- **Solution**: Switch to test keys in Stripe dashboard

#### "AWS access denied"
- Ensure IAM user has correct permissions
- Check AWS region settings
- **Solution**: Attach additional IAM policies or create new user

#### "Sentry not receiving errors"
- Verify DSN is correct
- Check project platform settings
- **Solution**: Regenerate DSN in Sentry project settings

### Recovery Steps:
1. Go back to the service's website
2. Navigate to API Keys/Credentials section
3. Generate new credentials
4. Update your `.env` file
5. Test the new credentials
6. If still failing, check service status pages

## 📝 Environment Variables Template

Create a `.env` file in your project root with these variables:

```env
# Database
CONNECTION_STRING=Your_SQL_Server_Connection_String_Here

# Authentication
JWT_SECRET=Your_JWT_Secret_Here

# Email Service
SENDGRID_API_KEY=Your_SendGrid_API_Key_Here

# Payment Processing
STRIPE_PUBLISHABLE_KEY=Your_Stripe_Publishable_Key_Here
STRIPE_SECRET_KEY=Your_Stripe_Secret_Key_Here

# Cloud Services
AWS_ACCESS_KEY_ID=Your_AWS_Access_Key_ID_Here
AWS_SECRET_ACCESS_KEY=Your_AWS_Secret_Access_Key_Here
AWS_DEFAULT_REGION=us-east-1

# Monitoring
SENTRY_DSN=Your_Sentry_DSN_Here
```

## 🎉 Success Checklist
- [ ] SQL Server connection tested successfully
- [ ] JWT secret generated and saved
- [ ] SendGrid API key working
- [ ] Stripe keys tested
- [ ] AWS credentials configured
- [ ] Sentry DSN set up
- [ ] `.env` file created with all variables
- [ ] All credentials backed up securely

**Next**: You're ready to start the Medical Care System! The application will use these credentials for database access, user authentication, email notifications, payment processing, cloud deployment, and error monitoring.
