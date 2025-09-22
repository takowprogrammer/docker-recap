#!/bin/bash
# Development environment startup script

echo "🚀 Starting Student Management System - Development Mode"
echo "=================================================="

# Load development environment
export $(cat ../configs/environments/env.dev | xargs)

# Create secrets directory if it doesn't exist
mkdir -p ../configs/secrets

# Create development secrets (not secure, for demo only)
echo "toto" > ../configs/secrets/api_username.txt
echo "python" > ../configs/secrets/api_password.txt
echo "student_pass" > ../configs/secrets/postgres_password.txt

echo "📦 Building images..."
docker-compose build

echo "🔄 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to be healthy..."
sleep 30

echo "🔍 Checking service health..."
docker-compose ps

echo ""
echo "✅ Services started successfully!"
echo ""
echo "🌐 Access points:"
echo "   Web Application: http://localhost:8080"
echo "   API Health:      http://localhost:8080/api/health"
echo "   Registry:        http://localhost:5000"
echo "   Registry UI:     http://localhost:8081"
echo ""
echo "📊 Monitor logs with:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Stop services with:"
echo "   docker-compose down"
