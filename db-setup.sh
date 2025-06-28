#!/bin/bash

# Database Management Script for Canine

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🗄️  Database Management${NC}"
echo ""

case "${1:-help}" in
    "setup")
        echo -e "${BLUE}Setting up database from scratch...${NC}"
        bundle exec rails db:drop db:create db:migrate db:seed
        echo -e "${GREEN}✅ Database setup complete${NC}"
        ;;
    "migrate")
        echo -e "${BLUE}Running pending migrations...${NC}"
        bundle exec rails db:migrate
        echo -e "${GREEN}✅ Migrations complete${NC}"
        ;;
    "rollback")
        echo -e "${BLUE}Rolling back last migration...${NC}"
        bundle exec rails db:rollback
        echo -e "${GREEN}✅ Rollback complete${NC}"
        ;;
    "reset")
        echo -e "${BLUE}Resetting database...${NC}"
        bundle exec rails db:reset
        echo -e "${GREEN}✅ Database reset complete${NC}"
        ;;
    "status")
        echo -e "${BLUE}Migration status:${NC}"
        bundle exec rails db:migrate:status
        ;;
    "console")
        echo -e "${BLUE}Opening database console...${NC}"
        bundle exec rails dbconsole
        ;;
    "help"|*)
        echo -e "${YELLOW}Available commands:${NC}"
        echo -e "  ${GREEN}./db-setup.sh setup${NC}    - Complete database setup (drop, create, migrate, seed)"
        echo -e "  ${GREEN}./db-setup.sh migrate${NC}  - Run pending migrations"
        echo -e "  ${GREEN}./db-setup.sh rollback${NC} - Rollback last migration"
        echo -e "  ${GREEN}./db-setup.sh reset${NC}    - Reset database (drop, create, migrate, seed)"
        echo -e "  ${GREEN}./db-setup.sh status${NC}   - Show migration status"
        echo -e "  ${GREEN}./db-setup.sh console${NC}  - Open database console"
        echo ""
        echo -e "${BLUE}Database Connection:${NC}"
        echo -e "  Host: localhost:5689"
        echo -e "  Database: canine_development"
        echo -e "  User: postgres"
        ;;
esac 