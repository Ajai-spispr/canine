#!/bin/bash

# Quick start script for development
# This script starts the Rails server and Sidekiq in separate processes

echo "🐕 Starting Canine Development Servers..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $RAILS_PID $SIDEKIQ_PID 2>/dev/null
    wait $RAILS_PID $SIDEKIQ_PID 2>/dev/null
    echo "✅ Servers stopped"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Start Rails server in background
echo "🚀 Starting Rails server on port 8034..."
bundle exec rails server -p 8034 &
RAILS_PID=$!

# Start Sidekiq in background
echo "⚡ Starting Sidekiq for background jobs..."
bundle exec sidekiq &
SIDEKIQ_PID=$!

echo ""
echo "✅ Development servers started!"
echo "📋 Service URLs:"
echo "  🌐 Web: http://localhost:8034"
echo "  🗄️  PostgreSQL: localhost:5689"
echo "  🔴 Redis: localhost:5690"
echo ""
echo "🔐 Login with: admin / secretpassword123"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Wait for processes
wait 