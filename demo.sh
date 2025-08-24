#!/usr/bin/env bash
set -euo pipefail

echo "🎯 Local CI/CD Pipeline Demo"
echo "============================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker Desktop."
    exit 1
fi

if ! command -v minikube &> /dev/null; then
    print_error "Minikube not found. Please install Minikube."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl."
    exit 1
fi

print_success "All prerequisites found!"

echo
print_status "Starting the demo..."

# Step 1: Start Minikube
print_status "Step 1: Starting Minikube..."
if ! minikube status >/dev/null 2>&1; then
    print_status "Starting Minikube cluster..."
    minikube start --driver=docker
else
    print_status "Minikube is already running."
fi
print_success "Minikube is ready!"

# Step 2: Start Jenkins
print_status "Step 2: Starting Jenkins..."
if ! docker ps | grep -q jenkins; then
    print_status "Building Jenkins image..."
    docker build -t cicd-jenkins:latest -f Dockerfile.jenkins .
    
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
    print_status "Jenkins is already running."
fi

echo
print_status "Step 3: Demo Access Points"
echo "================================"
echo
echo "🌐 Jenkins Dashboard:"
echo "   URL: http://localhost:8080"
echo "   Username: admin"
echo "   Password: admin123"
echo "   Job: hello-flask-cicd"
echo
echo "☸️  Kubernetes Dashboard:"
echo "   Command: minikube dashboard"
echo "   Note: Change namespace to 'demo' to see your resources"
echo
echo "🚀 Application:"
echo "   Health Check: http://localhost:8081/health"
echo "   Main App: http://localhost:8081/"
echo "   Port Forward: kubectl port-forward -n demo svc/hello-flask 8081:80"
echo

# Step 4: Check current deployment status
print_status "Step 4: Checking current deployment status..."
if kubectl get namespace demo >/dev/null 2>&1; then
    print_status "Demo namespace exists. Checking resources..."
    
    echo
    echo "📊 Current Resources:"
    echo "===================="
    
    echo "Pods:"
    kubectl get pods -n demo 2>/dev/null || echo "   No pods found"
    
    echo
    echo "Services:"
    kubectl get svc -n demo 2>/dev/null || echo "   No services found"
    
    echo
    echo "Deployments:"
    kubectl get deploy -n demo 2>/dev/null || echo "   No deployments found"
    
    echo
    print_status "Step 5: Testing Application"
    echo "================================"
    
    # Test if application is running
    if kubectl get pods -n demo | grep -q Running; then
        print_status "Application is running. Testing endpoints..."
        
        # Start port-forward in background
        print_status "Starting port-forward..."
        kubectl port-forward -n demo svc/hello-flask 8081:80 >/dev/null 2>&1 &
        PF_PID=$!
        
        # Wait for port-forward to be ready
        sleep 3
        
        # Test health endpoint
        print_status "Testing health endpoint..."
        if curl -s http://localhost:8081/health | grep -q "ok"; then
            print_success "Health check passed!"
        else
            print_warning "Health check failed or endpoint not ready"
        fi
        
        # Test main endpoint
        print_status "Testing main application endpoint..."
        if curl -s http://localhost:8081/ | grep -q "Hello, CI/CD"; then
            print_success "Application is responding!"
        else
            print_warning "Application endpoint not responding as expected"
        fi
        
        # Stop port-forward
        kill $PF_PID 2>/dev/null || true
        
    else
        print_warning "No running pods found. You may need to run the Jenkins pipeline first."
    fi
    
else
    print_status "Demo namespace doesn't exist yet. You'll need to run the Jenkins pipeline to deploy the application."
fi

echo
print_status "Step 6: Demo Commands"
echo "==========================="
echo
echo "🎮 Manual Testing Commands:"
echo "   # Test the application"
echo "   kubectl port-forward -n demo svc/hello-flask 8081:80 &"
echo "   curl http://localhost:8081/health"
echo "   curl http://localhost:8081/"
echo
echo "   # Scale the application"
echo "   kubectl scale -n demo deploy/hello-flask --replicas=3"
echo "   kubectl get pods -n demo"
echo
echo "   # View logs"
echo "   kubectl logs -n demo deploy/hello-flask"
echo
echo "   # Make changes and re-run pipeline"
echo "   echo '# Updated at \$(date)' >> app.py"
echo "   # Then go to Jenkins and run the pipeline again"
echo

print_status "Step 7: Next Steps"
echo "========================"
echo
echo "1. Open Jenkins: http://localhost:8080 (admin/admin123)"
echo "2. Go to the 'hello-flask-cicd' job"
echo "3. Click 'Build Now' to run the pipeline"
echo "4. Watch the Console Output to see the pipeline stages"
echo "5. Open Kubernetes Dashboard: minikube dashboard"
echo "6. Change namespace to 'demo' to see your resources"
echo

print_status "Step 8: Cleanup (when done)"
echo "=================================="
echo
echo "To clean up everything:"
echo "   docker compose down"
echo "   minikube stop"
echo "   kubectl delete namespace demo"
echo

print_success "Demo setup complete! 🎉"
echo
echo "Happy CI/CD-ing! 🚀"
