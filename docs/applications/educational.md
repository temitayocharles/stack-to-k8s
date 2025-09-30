# 🎓 Educational Platform - Online Learning Management System

**Technology**: Angular + Java Spring Boot + PostgreSQL  
**Difficulty**: ⭐⭐⭐ Medium  
**Time**: 30 minutes

> **Perfect for**: Learning enterprise Java architecture and Angular frameworks

## 🎯 What You'll Build
- ✅ **Course management system** with video streaming
- ✅ **Student progress tracking** with analytics
- ✅ **Interactive assignments** with automated grading
- ✅ **Real-time collaboration** with chat and forums
- ✅ **Advanced authentication** with role-based access

## 📋 Before You Start
**Required time**: 30 minutes  
**Prerequisites**: [System setup](../getting-started/system-setup.md) completed  
**Skills**: Basic understanding of Java and TypeScript helpful

## 🚀 Quick Start

### 1. Navigate to Application
```bash
cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/educational-platform
```

### 2. Start Everything
```bash
docker-compose up -d
```

### 3. Open in Browser
- **Frontend**: http://localhost:4001
- **API Documentation**: http://localhost:8001/swagger-ui.html
- **Admin Panel**: http://localhost:4001/admin

## 🔍 What's Inside

### Frontend Features (Angular)
- **Course catalog** with search and filtering
- **Video player** with progress tracking
- **Assignment submission** with file uploads
- **Discussion forums** with real-time updates
- **Dashboard analytics** for students and instructors

### Backend APIs (Spring Boot)
- **Course Management API** - CRUD operations for courses
- **User Management API** - Authentication and authorization
- **Assessment API** - Quiz and assignment handling
- **Analytics API** - Progress and performance metrics
- **File Storage API** - Video and document management

### Database Schema (PostgreSQL)
- **Users table** - Students, instructors, admins
- **Courses table** - Course metadata and content
- **Enrollments table** - Student-course relationships
- **Assessments table** - Quizzes and assignments
- **Progress table** - Learning analytics

## 🧪 Test It Out

### 1. Student Experience
1. Go to http://localhost:4001
2. Sign up as a new student
3. Browse available courses
4. Enroll in a course
5. Watch videos and complete assignments

### 2. Instructor Features
1. Log in with instructor credentials
2. Create a new course
3. Upload course materials
4. Create assignments and quizzes
5. View student progress analytics

### 3. Admin Functionality
1. Access admin panel at /admin
2. Manage users and permissions
3. View system analytics
4. Configure platform settings

## 🔧 Technical Details

### Frontend (Angular 15)
- **Angular Material** for consistent UI components
- **NgRx** for state management
- **RxJS** for reactive programming
- **Angular Router** with guards and resolvers
- **Lazy loading** for performance optimization

### Backend (Spring Boot 3)
- **Spring Security** with JWT authentication
- **Spring Data JPA** for database operations
- **Spring Boot Actuator** for monitoring
- **Swagger/OpenAPI** for API documentation
- **Spring WebSocket** for real-time features

### Database (PostgreSQL)
- **Flyway migrations** for schema versioning
- **Connection pooling** with HikariCP
- **Database indexing** for query optimization
- **ACID transactions** for data consistency

## 🚀 Kubernetes Deployment

Ready to deploy to Kubernetes?

### 1. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 2. Access via Port Forward
```bash
kubectl port-forward service/educational-frontend 4001:80
kubectl port-forward service/educational-backend 8001:8080
```

### 3. View in Browser
Go to http://localhost:4001

## 📊 Monitoring

### Check Application Health
```bash
curl http://localhost:8001/actuator/health
```

### View Database Connections
```bash
curl http://localhost:8001/actuator/metrics/hikaricp.connections
```

### Monitor Application Metrics
```bash
docker-compose logs -f educational-backend | grep "metrics"
```

## 🔄 Stop Application

```bash
docker-compose down
```

## ➡️ What's Next?

✅ **Master this app?** → [Try the medical system](medical.md) (enterprise .NET)  
✅ **Ready for advanced K8s?** → [Advanced Kubernetes features](../kubernetes/)  
✅ **Want CI/CD?** → [Setup automated pipelines](../getting-started/cicd-setup.md)

## 🆘 Need Help?

**Common issues**:
- **Database connection errors**: Wait for PostgreSQL to fully start (60 seconds)
- **Authentication failures**: Check JWT secret configuration
- **File upload issues**: Verify volume mounts and permissions

**More help**: [Troubleshooting guide](../troubleshooting/common-issues.md)

---

**Excellent choice!** The educational platform demonstrates enterprise Java patterns used in large-scale applications.