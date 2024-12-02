#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Utility functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    }
}

# Install Docker and Docker Compose if not installed
install_docker() {
    log_info "Installing Docker and Docker Compose..."
    
    # Update repositories
    apt-get update
    
    # Install dependencies
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up stable repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Start and enable Docker
    systemctl start docker
    systemctl enable docker

    # Verify installation
    docker --version
    docker compose version
}

# Set up directories and permissions
setup_directories() {
    log_info "Setting up directories..."
    
    # Create necessary directories
    mkdir -p secrets uploads logs docker/mariadb/{conf.d,init}
    
    # Generate secure passwords if they don't exist
    if [ ! -f secrets/db_root_password.txt ]; then
        openssl rand -base64 32 > secrets/db_root_password.txt
    fi
    
    if [ ! -f secrets/db_user.txt ]; then
        echo "innovation_user" > secrets/db_user.txt
    fi
    
    if [ ! -f secrets/db_password.txt ]; then
        openssl rand -base64 32 > secrets/db_password.txt
    fi
    
    # Set permissions
    chmod 600 secrets/*
    chmod 755 docker/mariadb/{conf.d,init}
}

# Deploy application
deploy_app() {
    log_info "Deploying application..."
    
    # Build and start containers
    docker compose build --no-cache
    docker compose up -d
    
    # Check container status
    docker compose ps
    
    # Wait for services to be healthy
    log_info "Waiting for services to be ready..."
    sleep 30
    
    # Check logs for errors
    docker compose logs --tail=100
}

# Main function
main() {
    log_info "Starting deployment..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then 
        log_error "This script must be run as root"
        exit 1
    }
    
    check_requirements
    install_docker
    setup_directories
    deploy_app
    
    log_info "Deployment completed successfully"
}

# Run script
main