# 🟢 **QUICK START - GET IT RUNNING IN 30 MINUTES**
## **No Complicated Stuff - Just Make It Work!**

> **🎯 Goal**: Get the e-commerce platform running so you can see what you're working with  
> **⏰ Time**: 30 minutes maximum  
> **🤝 Approach**: Copy, paste, click, done!  

---

## **Step 1: Download and Prepare (5 minutes)**

### **Copy this command and paste it in your terminal:**
```bash
cd /path/to/your/projects
git clone [repository-url]
cd ecommerce-app
```

**You will see:** A folder with lots of files downloads to your computer

**Next:** Open the folder in your code editor (VS Code works great)

**If this fails:** Make sure you have Git installed → [Git Setup Help](./git-setup.md)

---

## **Step 2: Start Everything (5 minutes)**

### **Copy this command and paste it:**
```bash
docker-compose up -d
```

**You will see:** Text scrolling showing things starting up

**Wait for:** All the scrolling to stop (usually 2-3 minutes)

**If you see errors:** Don't panic! → [Quick Error Fixes](./quick-fixes.md)

---

## **Step 3: Check It's Working (5 minutes)**

### **Open your web browser and go to:**
- **Frontend (the website)**: http://localhost:3001
- **Backend (the API)**: http://localhost:5001/health

**You should see:**
- A working online store website
- A page that says "API is healthy"

**If pages don't load:** Wait 2 more minutes, then → [Connection Issues](./connection-help.md)

---

## **Step 4: Explore Your Store (10 minutes)**

### **Try these things in the website:**
1. **Browse products**: Click around the store
2. **Add to cart**: Put some items in your shopping cart
3. **View cart**: See your items listed
4. **Try checkout**: Go through the purchase process (no real money!)

**You will see:** A fully working online store just like Amazon or any other e-commerce site

---

## **Step 5: Peek Behind the Scenes (5 minutes)**

### **See what's running with this command:**
```bash
docker ps
```

**You will see:** A list of all the services running (database, website, etc.)

### **Check the database:**
```bash
docker-compose exec mongodb mongosh --eval "db.products.find().limit(3)"
```

**You will see:** Sample products stored in the database

---

## 🎉 **Congratulations! You Did It!**

**You now have:**
- ✅ A real working e-commerce platform
- ✅ All services running in containers
- ✅ A database with sample data
- ✅ Experience with Docker commands

---

## **🚀 What's Next? (Choose One)**

### **Option A: Learn How It All Works**
**Perfect if you want to understand what just happened**
**👆 Click here:** [Understanding Your Store](./how-it-works.md)

### **Option B: Deploy to Kubernetes**
**Perfect if you want to practice Kubernetes now**
**👆 Click here:** [Kubernetes Deployment](./kubernetes-basics.md)

### **Option C: Stop and Clean Up**
**Perfect if you want to take a break**
**👆 Click here:** [How to Stop Everything](./cleanup.md)

---

## **🆘 Having Problems?**

### **Nothing is working?**
1. **First:** Make sure Docker is running on your computer
2. **Second:** Try this command: `docker-compose down && docker-compose up -d`
3. **Still stuck?** → [Troubleshooting Guide](./troubleshooting.md)

### **Want to start over?**
**Copy and paste this to reset everything:**
```bash
docker-compose down -v
docker-compose up -d
```

---

**🎯 Remember: This is just the beginning! You've already accomplished something great by getting a real application running. Every expert started exactly where you are now.**