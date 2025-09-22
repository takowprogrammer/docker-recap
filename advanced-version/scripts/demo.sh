#!/bin/bash
# Demonstration script for Docker concepts

echo "🎓 Docker DevOps Demonstration"
echo "=============================="
echo ""

# Function to show menu
show_menu() {
    echo "Select demonstration phase:"
    echo "1. Basic Version (Simple Docker setup)"
    echo "2. Advanced Version (Production-ready setup)"
    echo "3. Compare both versions"
    echo "4. Show Docker concepts"
    echo "5. Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
}

# Function to show basic version
show_basic() {
    echo ""
    echo "📚 BASIC VERSION DEMONSTRATION"
    echo "=============================="
    echo ""
    echo "This version demonstrates:"
    echo "• Simple containerization"
    echo "• Basic Docker networking"
    echo "• Volume mounting"
    echo "• Single environment configuration"
    echo ""
    echo "Files structure:"
    echo "basic-version/"
    echo "├── simple_api/          # Python Flask API"
    echo "├── website/             # PHP web application"
    echo "├── docker-compose.yml   # Simple orchestration"
    echo "└── README.md            # Documentation"
    echo ""
    echo "To run:"
    echo "cd basic-version && docker-compose up -d"
    echo ""
}

# Function to show advanced version
show_advanced() {
    echo ""
    echo "🚀 ADVANCED VERSION DEMONSTRATION"
    echo "================================="
    echo ""
    echo "This version demonstrates:"
    echo "• Multi-stage builds"
    echo "• Environment configuration"
    echo "• Health checks"
    echo "• Database integration"
    echo "• Secrets management"
    echo "• Image registry"
    echo "• Reverse proxy (Nginx)"
    echo "• Production readiness"
    echo ""
    echo "Files structure:"
    echo "advanced-version/"
    echo "├── services/"
    echo "│   ├── api/             # Multi-stage Python API"
    echo "│   ├── webapp/          # Enhanced PHP app"
    echo "│   ├── database/        # PostgreSQL setup"
    echo "│   └── nginx/           # Reverse proxy"
    echo "├── configs/"
    echo "│   ├── environments/    # Environment configs"
    echo "│   └── secrets/         # Secrets management"
    echo "├── scripts/             # Automation scripts"
    echo "└── docker-compose.yml   # Production orchestration"
    echo ""
    echo "To run:"
    echo "cd advanced-version && ./scripts/start-dev.sh"
    echo ""
}

# Function to compare versions
compare_versions() {
    echo ""
    echo "🔄 VERSION COMPARISON"
    echo "===================="
    echo ""
    echo "BASIC VERSION:"
    echo "• 2 containers (API + Webapp)"
    echo "• Simple networking"
    echo "• JSON file storage"
    echo "• Single environment"
    echo "• Basic security"
    echo "• No health monitoring"
    echo ""
    echo "ADVANCED VERSION:"
    echo "• 6+ containers (API + Webapp + DB + Nginx + Registry + UI)"
    echo "• Complex networking with reverse proxy"
    echo "• PostgreSQL database"
    echo "• Multiple environments (dev/prod)"
    echo "• Secrets management"
    echo "• Health monitoring"
    echo "• Image registry"
    echo "• Production-ready"
    echo ""
}

# Function to show Docker concepts
show_concepts() {
    echo ""
    echo "🐳 DOCKER CONCEPTS DEMONSTRATED"
    echo "==============================="
    echo ""
    echo "1. CONTAINERIZATION:"
    echo "   • Isolating applications"
    echo "   • Consistent environments"
    echo "   • Resource efficiency"
    echo ""
    echo "2. ORCHESTRATION:"
    echo "   • Docker Compose"
    echo "   • Service dependencies"
    echo "   • Health checks"
    echo ""
    echo "3. NETWORKING:"
    echo "   • Custom networks"
    echo "   • Service discovery"
    echo "   • Load balancing"
    echo ""
    echo "4. STORAGE:"
    echo "   • Volumes"
    echo "   • Data persistence"
    echo "   • Database integration"
    echo ""
    echo "5. SECURITY:"
    echo "   • Non-root containers"
    echo "   • Secrets management"
    echo "   • Network isolation"
    echo ""
    echo "6. PRODUCTION READINESS:"
    echo "   • Multi-stage builds"
    echo "   • Environment configuration"
    echo "   • Monitoring and logging"
    echo "   • Image registry"
    echo ""
}

# Main loop
while true; do
    show_menu
    case $choice in
        1) show_basic ;;
        2) show_advanced ;;
        3) compare_versions ;;
        4) show_concepts ;;
        5) echo "Goodbye! 👋"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
    clear
done
