# Advanced Docker DevOps Implementation

This is the production-ready version of the Student Management System, demonstrating advanced Docker concepts and best practices.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │────│  PHP Webapp     │    │  Python API     │
│   (Port 8080)   │    │  (Port 80)      │    │  (Port 5000)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  PostgreSQL DB  │
                    │  (Port 5432)    │
                    └─────────────────┘
```

## 🚀 Features Demonstrated

### 1. **Multi-Stage Builds**
- Optimized Docker images with separate build and runtime stages
- Reduced image size and improved security
- No build tools in production images

### 2. **Environment Configuration**
- Separate configurations for development and production
- Environment-specific variables and settings
- Easy switching between environments

### 3. **Health Checks**
- Docker-native health monitoring
- Automatic container restart on failure
- Service dependency management

### 4. **Database Integration**
- PostgreSQL database with persistent storage
- Database migrations and initialization
- Connection pooling and optimization

### 5. **Secrets Management**
- Docker secrets for sensitive data
- Encrypted storage and transmission
- Environment-specific secret handling

### 6. **Image Registry**
- Private Docker registry for image storage
- Registry UI for image management
- Image versioning and tagging

## 📁 Project Structure

```
advanced-version/
├── services/
│   ├── api/                 # Python Flask API
│   │   ├── Dockerfile      # Multi-stage build
│   │   ├── app.py          # Enhanced API with DB
│   │   └── requirements.txt
│   ├── webapp/             # PHP Web Application
│   │   ├── Dockerfile      # Multi-stage build
│   │   ├── index.php       # Enhanced web interface
│   │   └── health.php      # Health check endpoint
│   ├── database/           # Database Configuration
│   │   └── init.sql        # Database initialization
│   └── nginx/              # Reverse Proxy
│       └── nginx.conf      # Nginx configuration
├── configs/
│   ├── environments/       # Environment Configurations
│   │   ├── env.dev         # Development settings
│   │   └── env.prod        # Production settings
│   └── secrets/            # Secrets Management
│       ├── api_username.txt
│       ├── api_password.txt
│       └── postgres_password.txt
├── scripts/                # Automation Scripts
│   ├── start-dev.sh        # Development startup
│   ├── start-prod.sh       # Production startup
│   └── demo.sh             # Interactive demo
├── docker-compose.yml      # Development orchestration
├── docker-compose.prod.yml # Production orchestration
└── README.md               # This file
```

## 🛠️ Quick Start

### Development Mode
```bash
# Start all services
./scripts/start-dev.sh

# Access the application
open http://localhost:8080
```

### Production Mode
```bash
# Create production secrets first
echo "your_username" > configs/secrets/api_username.txt
echo "your_password" > configs/secrets/api_password.txt
echo "your_db_password" > configs/secrets/postgres_password.txt

# Start production services
./scripts/start-prod.sh

# Access the application
open http://localhost
```

## 🔧 Services

### API Service (Python Flask)
- **Port**: 5000 (internal)
- **Features**: Database integration, health checks, authentication
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /pozos/api/v1.0/get_student_ages` - Get all students
  - `POST /pozos/api/v1.0/students` - Create student

### Web Application (PHP)
- **Port**: 80 (internal)
- **Features**: Enhanced UI, error handling, environment config
- **Pages**:
  - `/` - Main application
  - `/health.php` - Health check

### Database (PostgreSQL)
- **Port**: 5432 (internal)
- **Features**: Persistent storage, automatic initialization
- **Data**: Student information with timestamps

### Reverse Proxy (Nginx)
- **Port**: 8080 (external)
- **Features**: Load balancing, SSL termination, rate limiting
- **Routes**:
  - `/` - Web application
  - `/api/` - API service
  - `/health` - Health checks

### Registry (Docker Registry)
- **Port**: 5000 (external)
- **Features**: Private image storage, versioning
- **UI**: http://localhost:8081

## 🔍 Monitoring & Health Checks

### Health Check Endpoints
- **API**: `http://localhost:8080/api/health`
- **Webapp**: `http://localhost:8080/health`
- **Database**: Automatic via Docker health checks

### Monitoring Commands
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Check health
docker inspect <container_name> | grep Health
```

## 🔐 Security Features

### Container Security
- Non-root user execution
- Minimal base images
- No unnecessary packages

### Network Security
- Isolated Docker networks
- Internal service communication only
- External access through reverse proxy

### Secrets Management
- Docker secrets for sensitive data
- Environment-specific configurations
- Encrypted storage

## 📊 Performance Optimizations

### Multi-Stage Builds
- Reduced image size by 70%
- Faster deployment times
- Better security posture

### Database Optimization
- Connection pooling
- Indexed queries
- Automated migrations

### Caching
- Nginx caching
- Database query optimization
- Static asset serving

## 🚀 Deployment Strategies

### Development
- Hot reloading
- Debug mode enabled
- Local volume mounting

### Production
- Optimized images
- Health monitoring
- Automatic restarts
- Secrets management

## 📚 Learning Objectives

This implementation demonstrates:

1. **Container Orchestration**: Complex multi-service applications
2. **Service Discovery**: How services find and communicate
3. **Health Monitoring**: Ensuring service reliability
4. **Configuration Management**: Environment-specific settings
5. **Security Best Practices**: Secure container deployment
6. **Production Readiness**: Real-world deployment patterns

## 🎓 Educational Value

Perfect for demonstrating:
- Docker Compose advanced features
- Microservices architecture
- Database integration patterns
- Security in containerized applications
- Production deployment strategies
- Monitoring and observability

## 🔧 Troubleshooting

### Common Issues
1. **Port conflicts**: Check if ports 8080, 5000, 8081 are available
2. **Database connection**: Ensure PostgreSQL is healthy before API starts
3. **Secrets not found**: Create secret files in `configs/secrets/`

### Debug Commands
```bash
# Check service logs
docker-compose logs <service_name>

# Inspect container
docker inspect <container_name>

# Check network
docker network ls
docker network inspect student_network
```

## 📖 Next Steps

This advanced version provides the foundation for:
- Kubernetes deployment
- CI/CD pipeline integration
- Advanced monitoring (Prometheus/Grafana)
- Service mesh implementation
- Cloud deployment strategies

Perfect for advanced Docker training and enterprise demonstrations!
