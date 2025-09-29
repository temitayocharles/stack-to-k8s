# ⚙️ Setup Requirements

## System Requirements

### Minimum Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **CPU**: 4 cores minimum
- **Storage**: 20GB free space
- **OS**: macOS, Linux, or Windows with WSL2

### Software Requirements

#### Required Tools
- **Docker Desktop** - Container runtime
- **Node.js 18+** - JavaScript runtime
- **Git** - Version control

#### Optional Tools
- **kubectl** - Kubernetes CLI (for K8s deployment)
- **VS Code** - Code editor with Docker extension
- **Postman** - API testing

## Installation Steps

### 1. Install Docker Desktop

**macOS:**
```bash
# Download from https://docker.com/products/docker-desktop
# Or use Homebrew
brew install --cask docker
```

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Windows:**
- Download Docker Desktop from docker.com
- Enable WSL2 integration

### 2. Install Node.js

```bash
# macOS with Homebrew
brew install node

# Linux
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### 3. Clone Repository

```bash
git clone https://github.com/your-username/full-stack-apps.git
cd full-stack-apps/social-media-platform
```

## Environment Setup

### 1. Copy Environment File

```bash
cp .env.example .env
```

### 2. Configure Environment Variables

Edit `.env` file:

```bash
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/socialmedia

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-jwt-key

# API Keys (optional for basic setup)
OPENAI_API_KEY=your-openai-key
UPLOADCARE_PUBLIC_KEY=your-uploadcare-key
```

### 3. Start Services

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

## Verification

Test that everything works:

```bash
# Test backend API
curl http://localhost:4000/health

# Test frontend (open in browser)
open http://localhost:3000

# Test database connection
docker-compose exec postgres psql -U postgres -c "\l"
```

## Port Configuration

Default ports used:
- **Frontend**: 3000
- **Backend**: 4000  
- **PostgreSQL**: 5432
- **Redis**: 6379

To change ports, edit `docker-compose.yml`:

```yaml
services:
  frontend:
    ports:
      - "3001:3000"  # Change external port to 3001
```

## Troubleshooting

**Common Issues:**

1. **Port conflicts**: Change ports in docker-compose.yml
2. **Containers won't start**: Run `docker system prune -f`
3. **Database errors**: Delete volumes: `docker-compose down -v`

**Get Help:**
- Check [troubleshooting guide](./troubleshooting.md)
- View container logs: `docker-compose logs [service-name]`