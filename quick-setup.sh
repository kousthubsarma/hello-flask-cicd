#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Quick Setup - Local CI/CD Pipeline"
echo "======================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    print_warning "$service_name may still be starting. Check manually."
    return 1
}

echo "📋 Checking Prerequisites..."
echo "============================"

# Check Docker
if ! command_exists docker; then
    print_error "Docker not found. Please install Docker Desktop first."
    echo "Visit: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi
print_success "Docker is running"

# Check Minikube
if ! command_exists minikube; then
    print_error "Minikube not found. Please install Minikube first."
    echo "Visit: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi
print_success "Minikube found"

# Check kubectl
if ! command_exists kubectl; then
    print_error "kubectl not found. Please install kubectl first."
    echo "Visit: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi
print_success "kubectl found"

echo
print_status "Starting Setup Process..."
echo "==============================="

# Step 1: Start Minikube
print_status "Step 1: Starting Minikube..."
if ! minikube status >/dev/null 2>&1; then
    print_status "Starting Minikube cluster with Docker driver..."
    minikube start --driver=docker
    print_success "Minikube started successfully"
else
    print_status "Minikube is already running"
fi

# Verify Minikube is working
if kubectl get nodes >/dev/null 2>&1; then
    print_success "Kubernetes cluster is accessible"
else
    print_error "Kubernetes cluster is not accessible"
    exit 1
fi

# Step 2: Build Jenkins Image
print_status "Step 2: Building Jenkins Image..."
if ! docker images | grep -q cicd-jenkins; then
    print_status "Building custom Jenkins image..."
    docker build -t cicd-jenkins:latest -f Dockerfile.jenkins .
    print_success "Jenkins image built successfully"
else
    print_status "Jenkins image already exists"
fi

# Step 3: Start Jenkins
print_status "Step 3: Starting Jenkins..."
if ! docker ps | grep -q jenkins; then
    print_status "Starting Jenkins with Docker Compose..."
    docker compose up -d
    
    print_status "Waiting for Jenkins to start (30 seconds)..."
    sleep 30
    
    if docker logs jenkins 2>&1 | grep -q "Jenkins is fully up and running"; then
        print_success "Jenkins is up and running!"
    else
        print_warning "Jenkins may still be starting. Check with: docker logs jenkins"
    fi
else
    print_status "Jenkins is already running"
fi

# Step 4: Verify Jenkins Access
print_status "Step 4: Verifying Jenkins Access..."
if wait_for_service "http://localhost:8080" "Jenkins"; then
    print_success "Jenkins is accessible at http://localhost:8080"
else
    print_warning "Jenkins may not be fully ready yet"
fi

echo
print_success "🎉 Setup Complete!"
echo "======================"
echo
echo "📋 Access Information:"
echo "====================="
echo
echo "🌐 Jenkins Dashboard:"
echo "   URL: http://localhost:8080"
echo "   Username: admin"
echo "   Password: admin123"
echo
echo "☸️  Kubernetes Dashboard:"
echo "   Command: minikube dashboard"
echo "   Note: Change namespace to 'demo' to see your resources"
echo
echo "🚀 Application (after pipeline run):"
echo "   Health Check: http://localhost:8081/health"
echo "   Main App: http://localhost:8081/"
echo "   Port Forward: kubectl port-forward -n demo svc/hello-flask 8081:80"
echo

echo "📋 Next Steps:"
echo "=============="
echo
echo "1. Open Jenkins: http://localhost:8080 (admin/admin123)"
echo "2. Create a new Pipeline job:"
echo "   - Click 'New Item'"
echo "   - Enter 'hello-flask-cicd' as name"
echo "   - Select 'Pipeline' and click OK"
echo "   - In Pipeline section, select 'Pipeline script' (NOT 'Pipeline script from SCM')"
echo "   - Copy and paste the contents of Jenkinsfile.simple into the script area"
echo "   - Click 'Save'"
echo "3. Run the job: Click 'Build Now'"
echo "4. Watch the Console Output to see the pipeline stages"
echo "5. Open Kubernetes Dashboard: minikube dashboard"
echo "6. Change namespace to 'demo' to see your resources"
echo

echo "🎮 Demo Commands:"
echo "================"
echo
echo "# Test the application (after pipeline runs)"
echo "kubectl port-forward -n demo svc/hello-flask 8081:80 &"
echo "curl http://localhost:8081/health"
echo "curl http://localhost:8081/"
echo
echo "# Scale the application"
echo "kubectl scale -n demo deploy/hello-flask --replicas=3"
echo "kubectl get pods -n demo"
echo
echo "# Make changes and re-run pipeline"
echo "echo '# Updated at \$(date)' >> app.py"
echo "# Then go to Jenkins and run the pipeline again"
echo

echo "🧹 Cleanup (when done):"
echo "======================"
echo
echo "docker compose down"
echo "minikube stop"
echo "kubectl delete namespace demo"
echo

print_success "Setup completed successfully! 🚀"
echo
echo "Happy CI/CD-ing! 🎉"
