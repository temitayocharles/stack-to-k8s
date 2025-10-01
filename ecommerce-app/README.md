# 🛒 **E-COMMERCE PLATFORM**
## **Learn Kubernetes with a Real Working Online Store**

> **✨ Built by Temitayo Charles Akinniranye (TCA-InfraForge)**  
> **🎯 Perfect for Kubernetes Practice**  
> **⭐ Difficulty Level: ⭐⭐⭐☆☆ (Beginner-Friendly)**  

This is a complete e-commerce platform with shopping cart, payment processing, and inventory management - just like the real online stores you use every day!

---

## **🚀 Want to Get Started? Don't Get Overwhelmed!**

### **🚀 Learning Platform Launcher (Recommended)**
```bash
# From the main directory, run:
cd .. && ./scripts/learn-kubernetes.sh
# Access the ultimate Kubernetes learning experience!
```

### **👆 Manual Setup:** [**GET STARTED - Choose Your Path**](./GET-STARTED.md)

**We'll guide you step by step. No information overload!**

---

## **🎯 DevOps Learning Opportunities**

### **🟢 Beginner Challenges**
- **Container Optimization**: Reduce image size by 70%
- **Environment Management**: Set up dev/staging/prod configs
- **Health Monitoring**: Implement comprehensive health checks
- **Time**: 2-3 hours | **Skills**: Docker fundamentals

### **🟡 Intermediate Challenges**  
- **Kubernetes Deployment**: Zero-downtime rolling updates
- **Data Persistence**: Production-grade MongoDB with backups
- **Service Mesh**: Implement Istio for advanced networking
- **Time**: 1-2 weeks | **Skills**: Kubernetes orchestration

### **🟠 Advanced Challenges**
- **CI/CD Pipeline**: Complete automated deployment workflow
- **GitOps**: ArgoCD-based declarative deployments  
- **Multi-Environment**: Dev/staging/prod environment strategy
- **Time**: 2-4 weeks | **Skills**: Automation & GitOps

### **🔴 Expert Challenges**
- **Production Monitoring**: Prometheus, Grafana, distributed tracing
- **Performance Optimization**: Handle 10x traffic increase
- **Security Hardening**: Enterprise-grade security implementation
- **Time**: 1-2 months | **Skills**: Production operations

**📚 Detailed Challenge Guide**: [DevOps Challenges](docs/devops-challenges.md)

---

## **🎯 What You'll Have When Done**

✅ **A real working online store** (add to cart, checkout, payments)  
✅ **Experience with Docker containers** (the foundation of Kubernetes)  
✅ **Hands-on Kubernetes practice** (deploy, scale, monitor)  
✅ **Portfolio project** (show employers you can build real applications)  
✅ **Full-stack knowledge** (frontend + backend + database + cache)  

---

## **🐳 Ready to Deploy? Two Easy Options!**

### **🚀 Option 1: Use Pre-Built Images (Fastest)**
```bash
# Images ready on DockerHub - just pull and run:
docker pull temitayocharles/ecommerce-backend:latest
docker pull temitayocharles/ecommerce-frontend:latest

# Or use docker-compose (recommended):
docker-compose up -d
```

### **🛠️ Option 2: Build Your Own (More Learning)**
```bash
# Great for practicing Docker skills:
docker-compose build
docker-compose up -d
```

**Both options work perfectly!** Choose based on your learning goals.

---

## **🏗️ What's Under the Hood**

**Frontend:** React website (what customers see)  
**Backend:** Node.js API (handles orders and business logic)  
**Database:** MongoDB (stores products and customer data)  
**Cache:** Redis (makes everything fast)  
**Containers:** Docker (packages everything for deployment)  
**Orchestration:** Kubernetes (scales and manages everything)  

---

## **📚 Documentation Structure**

**We keep things simple - choose what you need:**

- **🟢 [Quick Start](./docs/quick-start.md)** - Get it running in 30 minutes
- **🟡 [Step-by-Step Guide](./docs/step-by-step.md)** - Learn while building (2-3 hours)
- **🔴 [Production Deployment](./docs/production-deployment.md)** - Full enterprise setup
- **🛠️ [Setup Requirements](./docs/setup-requirements.md)** - Make sure you have what you need
- **❓ [Quick Fixes](./docs/quick-fixes.md)** - When things go wrong
- **📖 [How It Works](./docs/how-it-works.md)** - Understand the architecture

---

## **🆘 New to This? Start Here!**

**Feeling overwhelmed?** That's normal! Everyone starts somewhere.

**👆 Click this:** [**GET STARTED - Choose Your Path**](./GET-STARTED.md)

We'll help you pick the right starting point based on your experience level.

---

## **⚡ Quick Commands (For When You Know What You're Doing)**

```bash
# Get it running
docker-compose up -d

# Check if it's working
curl http://localhost:5001/health

# Stop everything
docker-compose down

# Reset everything
docker-compose down -v && docker-compose up -d
```

**More commands and explanations:** [Command Reference](./docs/commands.md)

---

**🎯 Ready to become a Kubernetes expert? Let's start with getting this e-commerce platform running!**

**👆 [GET STARTED NOW](./GET-STARTED.md)**