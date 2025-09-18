# 🔐 **STEP-BY-STEP VAULT SETUP GUIDE**
## **Complete Beginner's Guide to HashiCorp Vault**

> **🎯 Goal**: Set up enterprise-grade secret management in 30 minutes  
> **👤 Audience**: Complete beginners ("dummies")  
> **⏱️ Time**: 30-45 minutes  
> **📋 Result**: Working Vault with your secrets, ready for practice  

---

## **📋 BEFORE YOU START**

### **✅ Prerequisites Checklist**
**⏰ Time to complete: 5 minutes**

- [ ] **Computer Ready**: Mac, Windows, or Linux computer
- [ ] **Docker Installed**: We'll check this in Step 1
- [ ] **Internet Connection**: For downloading images
- [ ] **45 minutes**: Uninterrupted time
- [ ] **Text Editor**: Any text editor (VS Code, Notepad, etc.)

### **🎯 What You'll Accomplish**
- ✅ Run HashiCorp Vault locally
- ✅ Store secrets securely (passwords, API keys)
- ✅ Practice enterprise secret management
- ✅ Learn production-ready patterns
- ✅ Prepare for real-world projects

---

## **STEP 1: VERIFY DOCKER IS RUNNING**
**⏰ Time: 2-3 minutes**

### **1.1 Check if Docker is Installed**
**Click this → Open your terminal/command prompt**

**On Mac**: Press `Cmd + Space`, type "Terminal", press Enter
**On Windows**: Press `Win + R`, type "cmd", press Enter  
**On Linux**: Press `Ctrl + Alt + T`

### **1.2 Test Docker**
**Copy this command exactly → Paste in terminal → Press Enter**
```bash
docker --version
```

**✅ You should see**: Something like `Docker version 24.0.6`  
**❌ If you see**: "command not found"

### **🚨 If Docker is NOT installed:**
**Next → Go to this link**: [Docker Desktop Download](https://www.docker.com/products/docker-desktop/)  
**Next → Click "Download for [Your OS]"**  
**Next → Install the downloaded file**  
**Next → Start Docker Desktop**  
**Next → Come back here and try Step 1.2 again**

### **1.3 Verify Docker is Running**
**Copy this → Paste → Press Enter**
```bash
docker ps
```

**✅ You should see**: A table with headers (even if empty)  
**❌ If you see**: "Cannot connect to Docker daemon"

**Fix → Start Docker Desktop application**  
**Wait → 30 seconds for Docker to start**  
**Try again → `docker ps`**

---

## **STEP 2: DOWNLOAD THE VAULT PROJECT**
**⏰ Time: 3-5 minutes**

### **2.1 Choose Your Download Method**

#### **Option A: Git Clone (Recommended)**
**If you have Git installed:**
```bash
git clone https://github.com/temitayocharles/full-stack-apps.git
cd full-stack-apps/vault
```

#### **Option B: Direct Download**
**If you don't have Git:**
1. **Click this link**: [Download ZIP](https://github.com/temitayocharles/full-stack-apps/archive/main.zip)
2. **Next → Extract the ZIP file**
3. **Next → Open terminal in the extracted folder**
4. **Next → Navigate**: `cd full-stack-apps-main/vault`

### **2.2 Verify You're in the Right Place**
**Copy this → Paste → Press Enter**
```bash
ls
```

**✅ You should see files like:**
- `docker-compose.yml`
- `scripts/`
- `README.md`

**❌ If you don't see these files:**
**Fix → Navigate to the correct folder**: `cd vault` or `cd full-stack-apps/vault`

---

## **STEP 3: START VAULT CONTAINER**
**⏰ Time: 5-10 minutes**

### **3.1 Start Vault**
**Copy this exact command → Paste → Press Enter**
```bash
docker-compose up -d
```

**🔄 You will see**: Download progress bars (first time only)  
**⏱️ Wait**: 2-5 minutes for download and startup  

### **3.2 Verify Vault is Running**
**Copy this → Paste → Press Enter**
```bash
docker ps
```

**✅ You should see**: A container named `vault-learning` with status "Up"

### **3.3 Test Vault is Accessible**
**Copy this → Paste → Press Enter**
```bash
curl http://localhost:8200/v1/sys/health
```

**✅ You should see**: JSON response with "sealed":false

**❌ If you see**: Connection refused or timeout  
**Fix → Wait 30 more seconds and try again**

---

## **STEP 4: OPEN VAULT WEB INTERFACE**
**⏰ Time: 2 minutes**

### **4.1 Open Your Web Browser**
**Click → Open your favorite web browser** (Chrome, Firefox, Safari, Edge)

### **4.2 Navigate to Vault**
**Click in address bar → Type this exactly → Press Enter**
```
http://localhost:8200
```

### **4.3 You Should See**
**✅ Expected**: HashiCorp Vault login page  
**✅ Title**: "Vault" with a blue/dark interface  
**✅ Login box**: In the center of the page  

**❌ If you see**: "This site can't be reached"  
**Fix → Go back to Step 3 and verify Vault is running**

### **4.4 Login to Vault**
**In the login box:**
1. **Method → Make sure "Token" is selected** (should be default)
2. **Token field → Type exactly**: `vault-dev-token`
3. **Click → "Sign In" button**

**✅ You should see**: Vault dashboard with menu on the left

---

## **STEP 5: RUN THE AUTOMATED SETUP**
**⏰ Time: 10-15 minutes**

### **5.1 Return to Your Terminal**
**Click → Back to your terminal window** (where you ran docker-compose)

### **5.2 Run the Interactive Setup**
**Copy this → Paste → Press Enter**
```bash
./scripts/setup-vault-learning.sh
```

**❌ If you see**: "Permission denied"  
**Fix → Run**: `chmod +x ./scripts/setup-vault-learning.sh` then try again

### **5.3 Follow the Interactive Prompts**

#### **Prompt 1: Choose Applications**
**You will see**:
```
📝 What would you like to set up in Vault?

1) 🏪 E-commerce Application (Stripe, PayPal, Database)
2) 🎓 Educational Platform (Zoom SDK, Video conferencing)  
3) 🌤️  Weather Application (OpenWeather API, Redis)
4) 🏥 Medical Care System (Healthcare APIs, Compliance)
5) 📋 Task Management (Collaboration tools, Notifications)
6) 📱 Social Media Platform (Social APIs, Media storage)
7) 🎯 All Applications (Complete setup)
8) 🔧 Custom Setup (Manual secret entry)

Enter your choice (1-8):
```

**For beginners → Type**: `7` **→ Press Enter** (This sets up everything)

#### **Prompt 2: Choose Environments**
**You will see**:
```
🌍 Which environments do you want to configure?

1) Development only
2) Development + Staging  
3) Development + Staging + Production
4) Custom environments

Enter your choice (1-4):
```

**For beginners → Type**: `1` **→ Press Enter** (Development only)

### **5.4 Watch the Magic Happen**
**You will see**: Progress messages like:
- "🔧 Setting up secrets for ecommerce/development..."
- "🔧 Setting up secrets for educational/development..."
- And so on...

**⏱️ Wait**: 3-5 minutes for completion

**✅ Success message**:
```
╔════════════════════════════════════════════════════════════════╗
║  🎉 SUCCESS! Your Vault learning environment is ready!        ║
╚════════════════════════════════════════════════════════════════╝
```

---

## **STEP 6: EXPLORE YOUR SECRETS**
**⏰ Time: 10 minutes**

### **6.1 Go Back to Vault Web Interface**
**Click → Back to your browser tab** (http://localhost:8200)

### **6.2 Navigate to Secrets**
**In the Vault interface:**
1. **Click → "Secrets" in the left menu**
2. **You should see → "secret/" in the list**
3. **Click → "secret/"**

### **6.3 Explore Application Secrets**
**You will see folders like:**
- `applications/`

**Click → "applications/"**  
**You will see → Folders for each app**: `ecommerce/`, `educational/`, etc.

### **6.4 View E-commerce Secrets**
**Example walkthrough:**
1. **Click → "ecommerce/"**
2. **Click → "development/"**  
3. **Click → "database/"**
4. **You will see → Database credentials**: username, password, host, etc.

### **6.5 Try Different Applications**
**Go back and explore:**
- **Educational** → Zoom SDK credentials
- **Weather** → OpenWeather API keys  
- **E-commerce** → Stripe payment keys

---

## **STEP 7: USE SECRETS IN COMMAND LINE**
**⏰ Time: 5 minutes**

### **7.1 Set Environment Variables**
**Copy each line → Paste → Press Enter**
```bash
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="vault-dev-token"
```

### **7.2 List All Secret Paths**
**Copy this → Paste → Press Enter**
```bash
vault kv list secret/applications/
```

**✅ You should see**: List of applications (ecommerce, educational, etc.)

### **7.3 Get a Specific Secret**
**Copy this → Paste → Press Enter**
```bash
vault kv get secret/applications/ecommerce/development/database
```

**✅ You should see**: Database credentials in a table format

### **7.4 Add Your Own Secret**
**Copy this → Replace "your-api-key" with any value → Press Enter**
```bash
vault kv put secret/myapp/config api_key=your-api-key-here
```

### **7.5 Retrieve Your Secret**
**Copy this → Paste → Press Enter**
```bash
vault kv get secret/myapp/config
```

**✅ You should see**: Your secret displayed back to you

---

## **STEP 8: UNDERSTAND WHAT YOU'VE BUILT**
**⏰ Time: 5 minutes**

### **🎯 What You Now Have**
- ✅ **Enterprise Secret Manager**: Real HashiCorp Vault instance
- ✅ **6 Application Examples**: Different business scenarios  
- ✅ **Secure Storage**: Encrypted secret storage
- ✅ **Web Interface**: Easy secret management
- ✅ **Command Line Access**: Professional tools
- ✅ **Development Environment**: Ready for projects

### **🏢 Real-World Applications**
**What you learned applies to:**
- ✅ **Startups**: Secure API key management
- ✅ **Enterprises**: Multi-environment secret handling
- ✅ **DevOps**: Infrastructure automation
- ✅ **Cloud Platforms**: AWS, Azure, GCP integrations
- ✅ **Kubernetes**: Container secret injection

---

## **STEP 9: NEXT STEPS & LEARNING**
**⏰ Time: Ongoing**

### **9.1 Practice Scenarios**
**Try these exercises:**

#### **Beginner Practice**
1. **Add secrets for a new project**
2. **Create development vs production environments**
3. **Practice retrieving secrets via CLI and Web UI**

#### **Intermediate Practice**
1. **Set up application integration** (connect real apps to Vault)
2. **Create custom policies** (access control)
3. **Practice secret rotation** (changing passwords)

#### **Advanced Practice**  
1. **Deploy to Kubernetes** (real container orchestration)
2. **Set up authentication methods** (LDAP, AWS IAM)
3. **Implement auto-unsealing** (production readiness)

### **9.2 When Something Goes Wrong**

#### **🚨 Vault Won't Start**
**Try this:**
```bash
docker-compose down
docker-compose up -d
```

#### **🚨 Can't Access Web Interface**
**Check this:**
```bash
docker ps
# Should show vault-learning container
```

#### **🚨 Forgot Your Token**
**Default token**: `vault-dev-token`  
**Or check**: `docker-compose logs vault`

#### **🚨 Want to Start Over**
**Complete reset:**
```bash
docker-compose down -v
docker-compose up -d
./scripts/setup-vault-learning.sh
```

### **9.3 Learning Resources**

#### **Official Documentation**
- **Click**: [HashiCorp Vault Docs](https://www.vaultproject.io/docs)
- **Click**: [Vault CLI Reference](https://www.vaultproject.io/docs/commands)
- **Click**: [Best Practices](https://learn.hashicorp.com/vault)

#### **Hands-On Tutorials**
- **Click**: [Vault Getting Started](https://learn.hashicorp.com/tutorials/vault/getting-started-intro)
- **Click**: [Kubernetes Integration](https://learn.hashicorp.com/tutorials/vault/kubernetes-raft-deployment-guide)

---

## **🎉 CONGRATULATIONS!**

### **🏆 What You've Accomplished**
- ✅ **Deployed** enterprise-grade secret management
- ✅ **Configured** 6 different application scenarios
- ✅ **Practiced** with both Web UI and command line
- ✅ **Learned** industry-standard security patterns
- ✅ **Built** a foundation for real projects

### **💼 Resume Addition**
**You can now confidently add:**
- "**HashiCorp Vault**: Secret management and security"
- "**Container Orchestration**: Docker and container security"
- "**DevOps Tools**: Infrastructure as Code and automation"
- "**Security Best Practices**: Encrypted secret storage and access control"

### **🚀 You're Ready For**
- ✅ **Real Projects**: Apply this to actual applications
- ✅ **Job Interviews**: Demonstrate hands-on Vault experience
- ✅ **Advanced Learning**: Kubernetes, CI/CD, and cloud platforms
- ✅ **Team Projects**: Lead security initiatives

---

**🎯 Next time you need to store secrets securely, you know exactly how to do it professionally!**

*Remember: This setup is for learning. For production, always use proper authentication, TLS, and follow security best practices.*