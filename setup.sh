#!/bin/bash

# Hello Flask CI/CD Pipeline Setup Script
# This script automates the setup of the complete CI/CD pipeline

set -e  # Exit on any error

echo "🚀 Setting up Hello Flask CI/CD Pipeline..."

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Please run on a macOS system."
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew is already installed"
fi

# Install required tools
print_status "Installing required tools..."
brew install git python@3.12 kubectl minikube gh docker

# Check if Docker Desktop is running
if ! docker info &> /dev/null; then
    print_warning "Docker Desktop is not running. Starting Docker Desktop..."
    open -a Docker
    
    # Wait for Docker to start
    print_status "Waiting for Docker to start..."
    while ! docker info &> /dev/null; do
        sleep 5
    done
    print_success "Docker Desktop is running"
else
    print_success "Docker Desktop is already running"
fi

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found. Please create it with your Docker Hub credentials:"
    echo "DOCKERHUB_USERNAME=your_username"
    echo "DOCKERHUB_TOKEN=your_token"
    echo "GIT_REMOTE_URL=your_repo_url"
    exit 1
fi

# Load environment variables
source .env

# Validate environment variables
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_TOKEN" ]; then
    print_error "DOCKERHUB_USERNAME and DOCKERHUB_TOKEN must be set in .env file"
    exit 1
fi

# Login to Docker Hub
print_status "Logging in to Docker Hub..."
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
print_success "Logged in to Docker Hub"

# Start Minikube
print_status "Starting Minikube..."
if ! minikube status &> /dev/null; then
    minikube start --driver=docker
else
    print_success "Minikube is already running"
fi

# Set kubectl context
kubectl config use-context minikube
print_success "Kubernetes context set to minikube"

# Create Python virtual environment
print_status "Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
print_success "Python environment setup complete"

# Run tests
print_status "Running unit tests..."
PYTHONPATH=. pytest -q
print_success "All tests passed"

# Build and test Docker image
print_status "Building Docker image..."
docker build -t "$DOCKERHUB_USERNAME/hello-flask:latest" .
print_success "Docker image built successfully"

# Test Docker container locally
print_status "Testing Docker container..."
docker run -d -p 8000:8000 --name test-container "$DOCKERHUB_USERNAME/hello-flask:latest"
sleep 5
if curl -s http://localhost:8000/health | grep -q "ok"; then
    print_success "Docker container test passed"
else
    print_error "Docker container test failed"
    exit 1
fi
docker stop test-container && docker rm test-container

# Push Docker image
print_status "Pushing Docker image to Docker Hub..."
docker push "$DOCKERHUB_USERNAME/hello-flask:latest"
print_success "Docker image pushed successfully"

# Deploy to Kubernetes
print_status "Deploying to Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Update deployment with correct image
kubectl set image deployment/hello-flask -n demo hello-flask="$DOCKERHUB_USERNAME/hello-flask:latest"

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/hello-flask -n demo
print_success "Deployment is ready"

# Start Jenkins
print_status "Starting Jenkins..."
docker compose up -d
print_success "Jenkins started successfully"

# Wait for Jenkins to be ready
print_status "Waiting for Jenkins to be ready..."
sleep 30
if curl -s http://localhost:8080/ | grep -q "Jenkins"; then
    print_success "Jenkins is ready"
else
    print_warning "Jenkins may still be starting up. Check http://localhost:8080"
fi

# Test the deployed application
print_status "Testing deployed application..."
kubectl port-forward -n demo svc/hello-flask 8080:80 &
PF_PID=$!
sleep 5

if curl -s http://localhost:8080/ | grep -q "Hello"; then
    print_success "Application deployed successfully"
else
    print_error "Application deployment test failed"
    kill $PF_PID 2>/dev/null || true
    exit 1
fi

kill $PF_PID 2>/dev/null || true

# Final status
echo ""
print_success "🎉 CI/CD Pipeline Setup Complete!"
echo ""
echo "📋 Summary:"
echo "  ✅ All dependencies installed"
echo "  ✅ Docker Hub configured"
echo "  ✅ Minikube running"
echo "  ✅ Application deployed to Kubernetes"
echo "  ✅ Jenkins running"
echo ""
echo "🔗 Access Points:"
echo "  • Jenkins: http://localhost:8080"
echo "  • Application: kubectl port-forward -n demo svc/hello-flask 8080:80"
echo ""
echo "📚 Next Steps:"
echo "  1. Access Jenkins at http://localhost:8080"
echo "  2. Configure your Git repository"
echo "  3. Set up webhooks for automatic builds"
echo "  4. Monitor your pipeline"
echo ""
echo "📖 For more information, see README.md"
