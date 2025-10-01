# ⚡ Quick Deploy (10 minutes)

**Goal**: Get one application running to verify everything works.

## Step 1: Pick an Application (1 minute)

**Recommended for first deployment**: E-commerce App (most tested)

```bash
# Go to the ecommerce app
cd ecommerce-app
```

**Alternative options**: [→ All Applications](./applications-overview.md)

## Step 2: Deploy with Docker (3 minutes)

```bash
# Start all services
docker-compose up -d
```

**You will see**: Download messages as Docker pulls images.

**This creates**:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000  
- Database: MongoDB (internal)
- Cache: Redis (internal)

## Step 3: Test the Application (3 minutes)

### Test the Frontend
**Open your browser**: [http://localhost:3000](http://localhost:3000)

**You should see**: E-commerce website with products.

### Test the Backend API
```bash
# Test the API
curl http://localhost:5000/api/health
```

**You should see**: `{"status":"OK","timestamp":"..."}`

## Step 4: Explore the Application (3 minutes)

**Try these actions**:
1. Browse products on the homepage
2. Add items to cart
3. Create a user account
4. Place a test order

**All data is saved**: MongoDB stores everything.

## Step 5: Stop When Done (1 minute)

```bash
# Stop all services
docker-compose down
```

**This removes**: All containers but keeps your data.

---

**✅ Deployment Success**: [→ What's Next?](./next-steps.md)

**Had Issues?**: [→ Troubleshooting](./troubleshooting.md)