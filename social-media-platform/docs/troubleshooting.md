# 🛠️ Troubleshooting Guide

## Common Issues and Solutions

### Container Issues

**Problem: Containers won't start**
```bash
# Check container logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild containers
docker-compose down -v
docker-compose up -d --build
```

**Problem: Database connection failed**
```bash
# Check PostgreSQL is running
docker-compose ps

# Reset database
docker-compose down -v
docker-compose up -d postgres
# Wait 30 seconds for database to initialize
docker-compose up -d backend
```

### API Issues

**Problem: API returns 500 errors**
```bash
# Check backend logs
docker-compose logs backend

# Common fix: restart backend
docker-compose restart backend
```

**Problem: Authentication not working**
- Verify JWT_SECRET is set in environment variables
- Check that user registration worked correctly
- Try logging in with test credentials

### Frontend Issues

**Problem: Frontend shows blank page**
```bash
# Check if backend is accessible
curl http://localhost:4000/health

# Check frontend logs
docker-compose logs frontend

# Rebuild frontend
docker-compose up -d --build frontend
```

### Network Issues

**Problem: Services can't communicate**
```bash
# Check if all services are on same network
docker network ls
docker network inspect social-media-platform_default
```

## Quick Reset

If everything is broken, try a complete reset:

```bash
cd social-media-platform
docker-compose down -v --remove-orphans
docker system prune -f
docker-compose up -d --build
```

Wait 2-3 minutes for all services to start, then test:
- Frontend: http://localhost:3000
- Backend: http://localhost:4000/health