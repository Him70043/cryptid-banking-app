# CryptID Production Deployment Script
# Simple PowerShell script for Windows deployment

param(
    [switch]$Build,
    [switch]$Logs,
    [switch]$Stop,
    [switch]$Clean,
    [switch]$Help
)

function Write-Info($message) {
    Write-Host $message -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host $message -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host $message -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host $message -ForegroundColor Red
}

function Show-Help {
    Write-Info @"
CryptID Deployment Script

Usage: .\deploy.ps1 [OPTIONS]

Options:
  -Build    Build images before deploying
  -Logs     Show application logs
  -Stop     Stop all services
  -Clean    Clean up all containers and volumes
  -Help     Show this help message

Examples:
  .\deploy.ps1 -Build     # Build and deploy
  .\deploy.ps1            # Deploy with existing images
  .\deploy.ps1 -Logs      # View logs
  .\deploy.ps1 -Stop      # Stop services
  .\deploy.ps1 -Clean     # Clean everything
"@
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check Docker
    try {
        $null = docker --version 2>$null
        Write-Success "Docker is installed"
    }
    catch {
        Write-Error "Docker is not installed or not running"
        exit 1
    }
    
    # Check Docker Compose
    try {
        $null = docker-compose --version 2>$null
        Write-Success "Docker Compose is installed"
    }
    catch {
        Write-Error "Docker Compose is not installed"
        exit 1
    }
    
    # Check .env.prod file
    if (Test-Path ".env.prod") {
        Write-Success "Production environment file found"
    } else {
        Write-Warning ".env.prod file not found. Using defaults."
    }
}

function Start-Deployment {
    Write-Info "Starting CryptID deployment..."
    
    if ($Build) {
        Write-Warning "Building images..."
        docker-compose -f docker-compose.prod.yml build --no-cache
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed"
            exit 1
        }
    }
    
    Write-Warning "Starting services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Deployment successful!"
        Write-Info @"

Application URLs:
  Frontend: http://localhost
  API: http://localhost/api
  Health Check: http://localhost/health

To view logs: .\deploy.ps1 -Logs
To check status: docker-compose -f docker-compose.prod.yml ps
"@
    } else {
        Write-Error "Deployment failed"
        exit 1
    }
}

function Show-Logs {
    Write-Info "Showing application logs..."
    docker-compose -f docker-compose.prod.yml logs -f
}

function Stop-Services {
    Write-Warning "Stopping services..."
    docker-compose -f docker-compose.prod.yml down
    Write-Success "Services stopped"
}

function Clean-Everything {
    Write-Warning "Cleaning up everything..."
    docker-compose -f docker-compose.prod.yml down -v --remove-orphans
    docker system prune -f
    Write-Success "Cleanup complete"
}

# Main script logic
if ($Help) {
    Show-Help
    exit 0
}

if ($Logs) {
    Show-Logs
    exit 0
}

if ($Stop) {
    Stop-Services
    exit 0
}

if ($Clean) {
    Clean-Everything
    exit 0
}

# Default action: deploy
Test-Prerequisites
Start-Deployment