#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Local CI/CD Pipeline Setup"
echo "=============================="
echo

echo "📋 Prerequisites Check..."
echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop."
    exit 1
fi

echo "Checking Minikube..."
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube not found. Please install Minikube."
    exit 1
fi

echo "Checking kubectl..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

echo "✅ All prerequisites found!"
echo

echo "🔧 Starting Minikube..."
if ! minikube status >/dev/null 2>&1; then
    echo "Starting Minikube cluster..."
    minikube start --driver=docker
else
    echo "Minikube is already running."
fi

echo "✅ Minikube is ready!"
echo

echo "🐳 Building Jenkins Image..."
echo "Building custom Jenkins image with Docker and kubectl..."
docker build -t cicd-jenkins:latest -f Dockerfile.jenkins .

echo "✅ Jenkins image built successfully!"
echo

echo "🚀 Starting Jenkins..."
echo "Starting Jenkins with Docker Compose..."
docker compose up -d

echo "⏳ Waiting for Jenkins to start (30 seconds)..."
sleep 30

echo "🔍 Verifying Jenkins startup..."
if docker logs jenkins 2>&1 | grep -q "Jenkins is fully up and running"; then
    echo "✅ Jenkins is up and running!"
else
    echo "⚠️  Jenkins may still be starting. Check logs with: docker logs jenkins"
fi

echo
echo "🎉 SETUP COMPLETE!"
echo "=================="
echo
echo "📋 NEXT STEPS:"
echo "1. Open Jenkins: http://localhost:8080 (admin/admin123)"
echo "2. Create a new Pipeline job:"
echo "   - Click 'New Item'"
echo "   - Enter 'hello-flask-cicd' as name"
echo "   - Select 'Pipeline' and click OK"
echo "   - In Pipeline section, select 'Pipeline script' (NOT 'Pipeline script from SCM')"
echo "   - Copy and paste the contents of Jenkinsfile.simple into the script area"
echo "   - Click 'Save'"
echo "3. Run the job: Click 'Build Now'"
echo "4. View K8s dashboard: minikube dashboard"
echo
echo "🔧 MANUAL JOB CREATION:"
echo "   - Job Name: hello-flask-cicd"
echo "   - Type: Pipeline"
echo "   - Definition: Pipeline script (NOT from SCM)"
echo "   - Script: Copy contents of Jenkinsfile.simple"
echo
echo "📁 WORKSPACE: The entire project is mounted at /workspace in Jenkins"
echo "🐳 DOCKER: Jenkins has access to Docker socket for building images"
echo "☸️  KUBERNETES: Jenkins has access to kubectl and minikube config"
echo
echo "🎮 DEMO COMMANDS:"
echo "   # Test the application"
echo "   kubectl port-forward -n demo svc/hello-flask 8081:80 &"
echo "   curl http://localhost:8081/health"
echo "   curl http://localhost:8081/"
echo
echo "   # Scale the application"
echo "   kubectl scale -n demo deploy/hello-flask --replicas=3"
echo
echo "   # View resources"
echo "   kubectl get pods -n demo"
echo "   kubectl get svc -n demo"
echo
echo "🧹 CLEANUP:"
echo "   docker compose down"
echo "   minikube stop"
echo "   kubectl delete namespace demo"
echo
echo "Happy CI/CD-ing! 🚀"
