#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Auto-Deploy Script"
echo "===================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_status "Checking for new Docker image..."

# Pull the latest image
print_status "Pulling latest image from Docker Hub..."
docker pull kousthubsarma/hello-flask:latest

# Restart the deployment to use the new image
print_status "Restarting Kubernetes deployment..."
kubectl rollout restart -n demo deploy/hello-flask

# Wait for the deployment to complete
print_status "Waiting for deployment to complete..."
kubectl rollout status -n demo deploy/hello-flask

print_success "Deployment completed!"

# Show the new pods
print_status "New pods:"
kubectl get pods -n demo

print_success "🎉 Application updated successfully!"
echo
echo "Test the application:"
echo "curl http://localhost:8081/"
