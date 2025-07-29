# 🚀 CryptID - Quick Deployment Guide

## ⚠️ Prerequisites Required

Before deploying, you need to install Docker on your system:

### Windows
1. Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
2. Restart your computer after installation
3. Start Docker Desktop
4. Verify installation: Open PowerShell and run `docker --version`

### Linux (Ubuntu/Debian)
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

### macOS
1. Download and install [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
2. Start Docker Desktop
3. Verify installation: Open Terminal and run `docker --version`

## 🎯 One-Command Deployment

Once Docker is installed, deploy with a single command:

### Windows (PowerShell)
```powershell
# Navigate to project directory
cd "c:\Users\hraj5\OneDrive\Desktop\bank project"

# Deploy with Docker Compose
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

### Linux/macOS (Terminal)
```bash
# Navigate to project directory
cd "/path/to/bank project"

# Deploy with Docker Compose
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

## 🔍 Verify Deployment

After deployment, check if services are running:

```bash
# Check service status
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f
```

## 🌐 Access Your Application

Once deployed successfully:

- **Frontend**: http://localhost
- **API**: http://localhost/api
- **Health Check**: http://localhost/health

## 🛠️ Management Commands

### Stop Services
```bash
docker compose -f docker-compose.prod.yml down
```

### Update Application
```bash
# Pull latest changes (if using git)
git pull origin main

# Rebuild and redeploy
docker compose -f docker-compose.prod.yml up -d --build
```

### View Logs
```bash
# All services
docker compose -f docker-compose.prod.yml logs -f

# Specific service
docker compose -f docker-compose.prod.yml logs -f backend
```

### Clean Up
```bash
# Stop and remove everything
docker compose -f docker-compose.prod.yml down --volumes --remove-orphans

# Remove unused images
docker image prune -f
```

## 📁 Deployment Files Created

Your project now includes these deployment files:

- `docker-compose.prod.yml` - Production Docker Compose configuration
- `.env.prod` - Production environment variables
- `backend/Dockerfile` - Backend container configuration
- `frontend/Dockerfile` - Frontend container configuration
- `frontend/nginx.conf` - Frontend web server configuration
- `docker/nginx/nginx.prod.conf` - Reverse proxy configuration
- `deploy.ps1` - Windows deployment script
- `deploy.sh` - Linux/macOS deployment script
- `DEPLOYMENT.md` - Comprehensive deployment guide

## 🔐 Security Notes

**IMPORTANT**: The `.env.prod` file contains default passwords. For production use:

1. Change all passwords in `.env.prod`:
   ```
   POSTGRES_PASSWORD=your_secure_database_password
   REDIS_PASSWORD=your_secure_redis_password
   SECRET_KEY=your_very_long_and_secure_secret_key
   JWT_SECRET_KEY=your_jwt_secret_key
   ```

2. For HTTPS in production, uncomment SSL configuration in `docker/nginx/nginx.prod.conf`

## 🆘 Troubleshooting

### Common Issues

1. **Port 80 already in use**:
   ```bash
   # Check what's using port 80
   netstat -tulpn | grep :80
   # Stop the conflicting service or change port in docker-compose.prod.yml
   ```

2. **Docker not found**:
   - Ensure Docker Desktop is installed and running
   - Restart your terminal/PowerShell
   - On Windows, ensure Docker Desktop is added to PATH

3. **Permission denied (Linux)**:
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

4. **Services not starting**:
   ```bash
   # Check logs for errors
   docker compose -f docker-compose.prod.yml logs
   ```

## 📞 Support

If you encounter issues:
1. Check the logs first: `docker compose -f docker-compose.prod.yml logs`
2. Ensure Docker is properly installed and running
3. Verify all environment variables in `.env.prod`
4. Check that ports 80 and 443 are available

---

**Your CryptID application is ready for deployment! 🎉**