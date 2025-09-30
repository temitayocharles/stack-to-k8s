# 🛒 E-commerce Store - Your First Application

**Technology**: React + Node.js + MongoDB  
**Difficulty**: ⭐⭐ Easy  
**Time**: 20 minutes

> **Perfect for**: Learning the basics with familiar e-commerce concepts

## 🎯 What You'll Build
- ✅ **Product catalog** with search and filtering
- ✅ **Shopping cart** with add/remove functionality  
- ✅ **User authentication** with JWT tokens
- ✅ **Order management** with status tracking
- ✅ **Admin dashboard** for inventory management

## 🚀 Quick Start

### 1. Navigate to Application
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/ecommerce-app
```

### 2. Start Everything
```bash
docker-compose up -d
```

### 3. Open in Browser
- **Frontend**: http://localhost:3001
- **API Documentation**: http://localhost:5001/api/docs

## 🔍 What's Inside

### Frontend Features
- **Product browsing** with categories
- **Search functionality** with filters
- **Shopping cart** with quantity management
- **User registration** and login
- **Order history** and tracking

### Backend APIs
- **Products API** - CRUD operations for inventory
- **Users API** - Authentication and profiles
- **Orders API** - Cart and checkout management
- **Categories API** - Product organization

### Database Structure
- **Products collection** - Inventory and pricing
- **Users collection** - Customer accounts  
- **Orders collection** - Purchase history
- **Categories collection** - Product organization

## 🧪 Test It Out

### 1. Browse Products
1. Go to http://localhost:3001
2. You'll see a list of products
3. Click on any product for details
4. Use the search bar to find specific items

### 2. Shopping Cart
1. Click "Add to Cart" on any product
2. Click the cart icon to view items
3. Modify quantities or remove items
4. Proceed to checkout

### 3. User Account
1. Click "Sign Up" to create an account
2. Fill in the registration form
3. Log in with your credentials
4. View your profile and order history

## 🔧 Technical Details

### Frontend (React)
- **Framework**: React 18 with hooks
- **Styling**: Tailwind CSS for modern UI
- **State Management**: Context API for cart state
- **Routing**: React Router for navigation
- **HTTP Client**: Axios for API calls

### Backend (Node.js)
- **Framework**: Express.js with middleware
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Joi for request validation
- **Documentation**: Swagger/OpenAPI specs
- **Error Handling**: Custom error middleware

### Database (MongoDB)
- **ODM**: Mongoose for data modeling
- **Indexing**: Optimized queries for products and users
- **Validation**: Schema-level data validation
- **Aggregation**: Complex queries for analytics

## 🚀 Kubernetes Deployment

Ready to deploy to Kubernetes?

### 1. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 2. Access via Port Forward
```bash
kubectl port-forward service/ecommerce-frontend 3001:80
```

### 3. View in Browser
Go to http://localhost:3001

## 📊 Monitoring

### Check Application Health
```bash
curl http://localhost:5001/health
```

### View Logs
```bash
docker-compose logs -f ecommerce-backend
```

### Monitor Performance
```bash
docker stats
```

## 🔄 Stop Application

```bash
docker-compose down
```

## ➡️ What's Next?

✅ **Master this app?** → [Try the weather app](weather.md) (different tech stack)  
✅ **Ready for Kubernetes?** → [Kubernetes basics](../getting-started/kubernetes-basics.md)  
✅ **Want production setup?** → [Enterprise deployment](../deployment/production-ready.md)

## 🆘 Need Help?

**Common issues**:
- **Port conflicts**: Change ports in docker-compose.yml
- **Database connection**: Wait 30 seconds for MongoDB startup
- **Frontend not loading**: Check if Node.js backend is running

**More help**: [Troubleshooting guide](../troubleshooting/common-issues.md)

---

**Great choice!** The e-commerce app teaches you full-stack concepts that apply to most web applications.