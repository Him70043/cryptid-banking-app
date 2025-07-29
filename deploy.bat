@echo off
echo ========================================
echo CryptID Production Deployment
echo ========================================
echo.

:: Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://docs.docker.com/desktop/windows/install/
    echo.
    pause
    exit /b 1
)

echo ✓ Docker is installed

:: Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker daemon is not running
    echo Please start Docker Desktop and try again
    echo.
    pause
    exit /b 1
)

echo ✓ Docker daemon is running
echo.

:: Check if environment file exists
if not exist ".env.prod" (
    echo WARNING: .env.prod file not found
    echo Using default configuration...
    echo.
)

echo Starting deployment...
echo.

:: Deploy with Docker Compose
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Deployment failed
    echo Check the logs above for details
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✓ Deployment completed successfully!
echo ========================================
echo.
echo Your application is now running at:
echo   Frontend: http://localhost
echo   API: http://localhost/api
echo   Health: http://localhost/health
echo.
echo To view logs: docker compose -f docker-compose.prod.yml logs -f
echo To stop: docker compose -f docker-compose.prod.yml down
echo.
pause