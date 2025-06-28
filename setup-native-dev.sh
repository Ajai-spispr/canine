#!/bin/bash

# Canine Native Development Setup Script
# This script sets up native Rails development with PostgreSQL and Redis in Docker

echo "🐕 Setting up Canine for Native Rails Development..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
echo -e "${BLUE}🔍 Checking Docker...${NC}"
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Check Ruby version
echo -e "${BLUE}🔍 Checking Ruby version...${NC}"
if command -v ruby >/dev/null 2>&1; then
    RUBY_VERSION=$(ruby -v)
    echo -e "${GREEN}✅ Ruby found: $RUBY_VERSION${NC}"
    
    if ruby -e "exit(RUBY_VERSION >= '3.3.0' ? 0 : 1)" 2>/dev/null; then
        echo -e "${GREEN}✅ Ruby version is compatible${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Ruby 3.3.4 is recommended (current: $(ruby -v | awk '{print $2}'))${NC}"
    fi
else
    echo -e "${RED}❌ Ruby not found. Please install Ruby 3.3.4${NC}"
    echo "Install with: rbenv install 3.3.4 && rbenv global 3.3.4"
    exit 1
fi

# Check if Bundler is installed
echo -e "${BLUE}🔍 Checking Bundler...${NC}"
if ! command -v bundle >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installing Bundler...${NC}"
    gem install bundler
fi
echo -e "${GREEN}✅ Bundler ready${NC}"

# Copy environment file
echo -e "${BLUE}📝 Setting up environment...${NC}"
if [ ! -f .env ]; then
    cp .env.development .env
    echo -e "${GREEN}✅ .env file created${NC}"
else
    echo -e "${YELLOW}📝 .env file already exists${NC}"
fi

# Start databases with Docker
echo -e "${BLUE}🗄️  Starting databases...${NC}"
docker-compose -f docker-compose.databases.yml down
docker-compose -f docker-compose.databases.yml up -d

# Wait for databases to be ready
echo -e "${BLUE}⏳ Waiting for databases to be ready...${NC}"
sleep 5

# Check database connectivity
echo -e "${BLUE}🔍 Testing database connectivity...${NC}"
until docker-compose -f docker-compose.databases.yml exec -T postgres pg_isready -U postgres -d canine_development >/dev/null 2>&1; do
    echo -e "${YELLOW}⏳ Waiting for PostgreSQL...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ PostgreSQL is ready${NC}"

until docker-compose -f docker-compose.databases.yml exec -T redis redis-cli ping >/dev/null 2>&1; do
    echo -e "${YELLOW}⏳ Waiting for Redis...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ Redis is ready${NC}"

# Install gems
echo -e "${BLUE}💎 Installing gems...${NC}"
bundle install

# Setup database
echo -e "${BLUE}🗄️  Setting up database...${NC}"
echo -e "${YELLOW}   Creating database: canine_development${NC}"
bundle exec rails db:create

echo -e "${YELLOW}   Running migrations (37 migration files)...${NC}"
bundle exec rails db:migrate

echo -e "${YELLOW}   Checking if seeds are needed...${NC}"
bundle exec rails db:seed

echo -e "${GREEN}✅ Database setup complete${NC}"

# Setup assets
echo -e "${BLUE}🎨 Setting up assets...${NC}"
bundle exec rails assets:precompile

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Service Information:${NC}"
echo -e "  🌐 Web Application: ${GREEN}http://localhost:8034${NC}"
echo -e "  🗄️  PostgreSQL: ${GREEN}localhost:5689${NC}"
echo -e "  🔴 Redis: ${GREEN}localhost:5690${NC}"
echo ""
echo -e "${BLUE}🔐 Authentication:${NC}"
echo -e "  Username: ${GREEN}admin${NC}"
echo -e "  Password: ${GREEN}secretpassword123${NC}"
echo ""
echo -e "${BLUE}🚀 To start development:${NC}"
echo -e "  ${YELLOW}# Terminal 1 - Rails Server${NC}"
echo -e "  ${GREEN}bundle exec rails server -p 8034${NC}"
echo ""
echo -e "  ${YELLOW}# Terminal 2 - Sidekiq (Background Jobs)${NC}"
echo -e "  ${GREEN}bundle exec sidekiq${NC}"
echo ""
echo -e "${BLUE}🛠️  Useful Commands:${NC}"
echo -e "  View database logs: ${GREEN}docker-compose -f docker-compose.databases.yml logs -f postgres${NC}"
echo -e "  View redis logs: ${GREEN}docker-compose -f docker-compose.databases.yml logs -f redis${NC}"
echo -e "  Stop databases: ${GREEN}docker-compose -f docker-compose.databases.yml down${NC}"
echo -e "  Rails console: ${GREEN}bundle exec rails console${NC}"
echo -e "  Run tests: ${GREEN}bundle exec rspec${NC}"
echo ""
echo -e "${GREEN}📖 Ready to code! Open http://localhost:8034 in your browser${NC}" 