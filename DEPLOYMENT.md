# CryptID - Production Deployment Guide

This guide provides comprehensive instructions for deploying the CryptID application in a production environment.

## 📋 Prerequisites

### System Requirements
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Operating System**: Windows 10/11, Linux, or macOS
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: Minimum 10GB free space

### Installation

#### Windows
1. Install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
2. Ensure WSL2 is enabled
3. Start Docker Desktop

#### Linux
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### macOS
1. Install [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
2. Start Docker Desktop

## 🚀 Quick Start

### 1. Environment Configuration

1. Copy the environment template:
   ```bash
   cp .env.prod.example .env.prod
   ```

2. Edit `.env.prod` with your production values:
   ```bash
   # Required: Generate secure passwords
   POSTGRES_PASSWORD=your_secure_database_password
   REDIS_PASSWORD=your_secure_redis_password
   SECRET_KEY=your_very_long_and_secure_secret_key
   JWT_SECRET_KEY=your_jwt_secret_key
   
   # Optional: Email configuration
   MAIL_USERNAME=your_email@gmail.com
   MAIL_PASSWORD=your_app_password
   
   # Optional: Domain configuration
   FRONTEND_URL=https://yourdomain.com
   ```

### 2. Deploy the Application

#### Windows (PowerShell)
```powershell
# Build and deploy
.\deploy.ps1 -Build

# Or deploy with existing images
.\deploy.ps1
```

#### Linux/macOS
```bash
# Make script executable (Linux/macOS only)
chmod +x deploy.sh

# Build and deploy
./deploy.sh --build

# Or deploy with existing images
./deploy.sh
```

### 3. Verify Deployment

After deployment, verify the services are running:

```bash
docker-compose -f docker-compose.prod.yml ps
```

Access the application:
- **Frontend**: http://localhost
- **API**: http://localhost/api
- **Health Check**: http://localhost/health

## 🔧 Deployment Commands

### Windows PowerShell
```powershell
# Deploy with fresh build
.\deploy.ps1 -Build

# Deploy without building
.\deploy.ps1

# View logs
.\deploy.ps1 -Logs

# Stop services
.\deploy.ps1 -Stop

# Clean up everything
.\deploy.ps1 -Clean

# Show help
.\deploy.ps1 -Help
```

### Linux/macOS Bash
```bash
# Deploy with fresh build
./deploy.sh --build

# Deploy without building
./deploy.sh

# View logs
./deploy.sh --logs

# Stop services
./deploy.sh --stop

# Clean up everything
./deploy.sh --clean

# Show help
./deploy.sh --help
```

## 🏗️ Architecture Overview

The production deployment includes:

### Services
1. **PostgreSQL Database** - Primary data storage
2. **Redis** - Caching and session storage
3. **Backend API** - Flask application with Gunicorn
4. **Frontend** - React application served by Nginx
5. **Nginx Proxy** - Reverse proxy and load balancer

### Network Architecture
```
Internet → Nginx (Port 80/443) → Frontend (Port 80) / Backend (Port 5000)
                                ↓
                         PostgreSQL (Port 5432)
                                ↓
                           Redis (Port 6379)
```

## 🔒 Security Features

### Built-in Security
- **Rate Limiting**: API and login endpoints
- **CORS Protection**: Configured origins
- **Security Headers**: XSS, CSRF, Content-Type protection
- **Non-root Containers**: All services run as non-root users
- **Network Isolation**: Services communicate via internal network

### SSL/HTTPS Setup (Production)

1. Obtain SSL certificates (Let's Encrypt recommended)
2. Place certificates in `./docker/nginx/ssl/`
3. Uncomment HTTPS configuration in `docker/nginx/nginx.prod.conf`
4. Update environment variables:
   ```bash
   FRONTEND_URL=https://yourdomain.com
   ```

## 📊 Monitoring and Logs

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
```

### Health Checks
All services include health checks:
- **Database**: PostgreSQL connection test
- **Redis**: Redis ping test
- **Backend**: HTTP health endpoint
- **Frontend**: HTTP availability test
- **Nginx**: HTTP proxy test

### Service Status
```bash
docker-compose -f docker-compose.prod.yml ps
```

## 🔄 Updates and Maintenance

### Update Application
```bash
# Pull latest code
git pull origin main

# Rebuild and redeploy
./deploy.sh --build  # Linux/macOS
.\deploy.ps1 -Build  # Windows
```

### Database Backup
```bash
# Create backup
docker exec cryptid_db_prod pg_dump -U cryptid_user cryptid > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker exec -i cryptid_db_prod psql -U cryptid_user cryptid < backup_file.sql
```

### Scale Services
```bash
# Scale backend to 3 instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

## 🐛 Troubleshooting

### Common Issues

#### Services Won't Start
1. Check Docker is running: `docker ps`
2. Check logs: `docker-compose -f docker-compose.prod.yml logs`
3. Verify environment file: `.env.prod`
4. Check port conflicts: `netstat -tulpn | grep :80`

#### Database Connection Issues
1. Verify PostgreSQL is healthy: `docker-compose -f docker-compose.prod.yml ps`
2. Check database logs: `docker-compose -f docker-compose.prod.yml logs db`
3. Verify credentials in `.env.prod`

#### Frontend Not Loading
1. Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`
2. Verify frontend build: `docker-compose -f docker-compose.prod.yml logs frontend`
3. Check browser console for errors

### Performance Optimization

#### Resource Limits
Adjust resource limits in `docker-compose.prod.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
```

#### Database Optimization
1. Increase shared_buffers in PostgreSQL
2. Configure connection pooling
3. Set up read replicas for scaling

## 📝 Environment Variables Reference

### Required Variables
| Variable | Description | Example |
|----------|-------------|----------|
| `POSTGRES_PASSWORD` | Database password | `secure_db_password` |
| `REDIS_PASSWORD` | Redis password | `secure_redis_password` |
| `SECRET_KEY` | Flask secret key | `your-secret-key-here` |
| `JWT_SECRET_KEY` | JWT signing key | `your-jwt-secret` |

### Optional Variables
| Variable | Description | Default |
|----------|-------------|----------|
| `POSTGRES_DB` | Database name | `cryptid` |
| `POSTGRES_USER` | Database user | `cryptid_user` |
| `FRONTEND_URL` | Frontend URL | `http://localhost` |
| `MAIL_SERVER` | SMTP server | `smtp.gmail.com` |
| `MAIL_PORT` | SMTP port | `587` |

## 🆘 Support

For deployment issues:
1. Check the logs first
2. Verify all prerequisites are met
3. Ensure environment variables are correctly set
4. Check Docker and Docker Compose versions

## 📄 License

This deployment configuration is part of the CryptID project.