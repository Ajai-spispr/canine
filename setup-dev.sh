#!/bin/bash

# Canine Development Setup Script
# This script sets up the development environment with custom ports

echo "🐕 Setting up Canine for local development..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# Development Environment Configuration
# Database Configuration
DATABASE_URL=postgres://postgres:password@localhost:5689/canine_development

# Redis Configuration  
REDIS_URL=redis://localhost:5690

# Application Configuration
PORT=8034
APP_HOST=http://localhost:8034
RAILS_ENV=development
LOCAL_MODE=true

# Authentication (customize these!)
CANINE_USERNAME=admin
CANINE_PASSWORD=secretpassword123

# Rails Configuration
SECRET_KEY_BASE=a38fcb39d60f9d146d2a0053a25024b9

# Docker Socket (for local development)
DOCKER_SOCKET=/var/run/docker.sock
EOF
    echo "✅ .env file created"
else
    echo "📝 .env file already exists"
fi

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker-compose -f docker-compose.dev.yml down

# Remove any existing volumes (optional, uncomment if needed)
# echo "🧹 Cleaning up existing volumes..."
# docker volume rm canine_postgres_dev 2>/dev/null || true

# Build and start the containers
echo "🏗️  Building and starting containers..."
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Service Information:"
echo "  🌐 Web Application: http://localhost:8034"
echo "  🗄️  PostgreSQL: localhost:5689"
echo "  🔴 Redis: localhost:5690"
echo ""
echo "🔐 Authentication:"
echo "  Username: admin"
echo "  Password: secretpassword123"
echo ""
echo "🛠️  Useful Commands:"
echo "  View logs: docker-compose -f docker-compose.dev.yml logs -f"
echo "  Stop services: docker-compose -f docker-compose.dev.yml down"
echo "  Restart services: docker-compose -f docker-compose.dev.yml restart"
echo "  Enter web container: docker-compose -f docker-compose.dev.yml exec web bash"
echo ""
echo "📖 Open http://localhost:8034 in your browser to access Canine!" 