#!/bin/bash
# Production environment startup script

echo "🚀 Starting Student Management System - Production Mode"
echo "====================================================="

# Load production environment
export $(cat ../configs/environments/env.prod | xargs)

# Create secrets directory if it doesn't exist
mkdir -p ../configs/secrets

# Check if secrets exist
if [ ! -f "../configs/secrets/api_username.txt" ]; then
    echo "❌ Error: Production secrets not found!"
    echo "Please create the following files:"
    echo "   ../configs/secrets/api_username.txt"
    echo "   ../configs/secrets/api_password.txt"
    echo "   ../configs/secrets/postgres_password.txt"
    exit 1
fi

echo "📦 Building images..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

echo "🔄 Starting services..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to be healthy..."
sleep 30

echo "🔍 Checking service health..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

echo ""
echo "✅ Services started successfully!"
echo ""
echo "🌐 Access points:"
echo "   Web Application: http://localhost"
echo "   API Health:      http://localhost/api/health"
echo ""
echo "📊 Monitor logs with:"
echo "   docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 Stop services with:"
echo "   docker-compose -f docker-compose.yml -f docker-compose.prod.yml down"
