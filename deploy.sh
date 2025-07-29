#!/bin/bash

# CryptID Production Deployment Script
# Bash script for Linux/Mac deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="prod"
BUILD=false
NO_BUILD=false
LOGS=false
STOP=false
CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        --no-build)
            NO_BUILD=true
            shift
            ;;
        -l|--logs)
            LOGS=true
            shift
            ;;
        -s|--stop)
            STOP=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

show_help() {
    echo -e "${BLUE}CryptID Deployment Script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment <env>  Environment to deploy (default: prod)"
    echo "  -b, --build             Force rebuild of Docker images"
    echo "  --no-build              Skip building, use existing images"
    echo "  -l, --logs              Show container logs"
    echo "  -s, --stop              Stop all services"
    echo "  -c, --clean             Clean up containers and images"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Deploy with existing images"
    echo "  $0 --build             # Deploy with fresh build"
    echo "  $0 --logs              # Show logs"
    echo "  $0 --stop              # Stop all services"
    echo "  $0 --clean             # Clean up everything"
}

check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Docker is installed${NC}"
    else
        echo -e "${RED}✗ Docker is not installed${NC}"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}✓ Docker Compose is installed${NC}"
    else
        echo -e "${RED}✗ Docker Compose is not installed${NC}"
        exit 1
    fi
    
    # Check if Docker is running
    if docker ps &> /dev/null; then
        echo -e "${GREEN}✓ Docker daemon is running${NC}"
    else
        echo -e "${RED}✗ Docker daemon is not running${NC}"
        exit 1
    fi
}

check_environment_file() {
    local env_file=".env.$ENVIRONMENT"
    if [[ ! -f "$env_file" ]]; then
        echo -e "${YELLOW}Warning: $env_file not found${NC}"
        echo -e "${YELLOW}Please copy .env.prod.example to $env_file and configure it${NC}"
        
        read -p "Continue without environment file? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Environment file $env_file found${NC}"
    fi
}

stop_services() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose -f docker-compose.prod.yml down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

clean_up() {
    echo -e "${YELLOW}Cleaning up containers and images...${NC}"
    
    # Stop services
    stop_services
    
    # Remove containers
    docker-compose -f docker-compose.prod.yml down --volumes --remove-orphans
    
    # Remove images
    docker image prune -f
    docker volume prune -f
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

build_images() {
    echo -e "${BLUE}Building Docker images...${NC}"
    
    # Build backend
    echo -e "${YELLOW}Building backend image...${NC}"
    docker build -t cryptid-backend:latest ./backend
    
    # Build frontend
    echo -e "${YELLOW}Building frontend image...${NC}"
    docker build -t cryptid-frontend:latest ./frontend
    
    echo -e "${GREEN}✓ Images built successfully${NC}"
}

deploy_services() {
    echo -e "${BLUE}Deploying services...${NC}"
    
    local env_file=".env.$ENVIRONMENT"
    local compose_args="-f docker-compose.prod.yml"
    
    if [[ -f "$env_file" ]]; then
        compose_args="$compose_args --env-file $env_file"
    fi
    
    # Start services
    docker-compose $compose_args up -d
    
    echo -e "${GREEN}✓ Services deployed successfully${NC}"
    
    # Wait for services to be healthy
    echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
    sleep 10
    
    # Check service status
    docker-compose $compose_args ps
}

show_logs() {
    echo -e "${BLUE}Showing container logs...${NC}"
    docker-compose -f docker-compose.prod.yml logs -f
}

show_status() {
    echo -e "${BLUE}Service Status:${NC}"
    docker-compose -f docker-compose.prod.yml ps
    
    echo -e "${BLUE}\nApplication URLs:${NC}"
    echo -e "${GREEN}Frontend: http://localhost${NC}"
    echo -e "${GREEN}API: http://localhost/api${NC}"
    echo -e "${GREEN}Health Check: http://localhost/health${NC}"
}

# Main execution
echo -e "${BLUE}CryptID Production Deployment${NC}"
echo -e "${BLUE}=============================${NC}"

check_prerequisites

if [[ "$CLEAN" == true ]]; then
    clean_up
    exit 0
fi

if [[ "$STOP" == true ]]; then
    stop_services
    exit 0
fi

if [[ "$LOGS" == true ]]; then
    show_logs
    exit 0
fi

check_environment_file

if [[ "$BUILD" == true && "$NO_BUILD" != true ]]; then
    build_images
fi

deploy_services
show_status

echo -e "${GREEN}\n✓ Deployment completed successfully!${NC}"
echo -e "${YELLOW}\nTo view logs: $0 --logs${NC}"
echo -e "${YELLOW}To stop services: $0 --stop${NC}"