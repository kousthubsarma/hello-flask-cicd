.PHONY: help setup test build deploy clean logs status

# Default target
help:
	@echo "Hello Flask CI/CD Pipeline - Available Commands"
	@echo "==============================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  setup          - Quick setup (prerequisites + basic deployment)"
	@echo "  install        - Install Python dependencies"
	@echo ""
	@echo "Development:"
	@echo "  test           - Run unit tests"
	@echo "  test-coverage  - Run tests with coverage"
	@echo "  lint           - Run linting checks"
	@echo ""
	@echo "Docker:"
	@echo "  build          - Build Docker image"
	@echo "  build-local    - Build local Docker image"
	@echo "  push           - Push Docker image to registry"
	@echo ""
	@echo "Kubernetes:"
	@echo "  deploy         - Deploy to Kubernetes"
	@echo "  deploy-local   - Deploy with local image"
	@echo "  status         - Show Kubernetes status"
	@echo "  logs           - Show application logs"
	@echo "  port-forward   - Port forward to application"
	@echo ""
	@echo "Jenkins:"
	@echo "  jenkins-start  - Start Jenkins"
	@echo "  jenkins-stop   - Stop Jenkins"
	@echo "  jenkins-logs   - Show Jenkins logs"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean          - Clean up resources"
	@echo "  clean-all      - Clean up everything"

# Setup
setup:
	@echo "🚀 Running quick setup..."
	./quick-setup.sh

install:
	@echo "📦 Installing Python dependencies..."
	pip install -r requirements.txt

# Testing
test:
	@echo "🧪 Running tests..."
	pytest -v tests/

test-coverage:
	@echo "🧪 Running tests with coverage..."
	pytest --cov=app --cov-report=html tests/
	@echo "📊 Coverage report generated in htmlcov/"

lint:
	@echo "🔍 Running linting checks..."
	flake8 app.py tests/
	pylint app.py

# Docker
build:
	@echo "🐳 Building Docker image..."
	docker build -t hello-flask:latest .

build-local:
	@echo "🐳 Building local Docker image..."
	docker build -t hello-flask:local .

push:
	@echo "📤 Pushing Docker image..."
	@if [ -z "$(DOCKERHUB_USERNAME)" ]; then \
		echo "❌ DOCKERHUB_USERNAME not set. Please set it in .env file"; \
		exit 1; \
	fi
	docker tag hello-flask:latest $(DOCKERHUB_USERNAME)/hello-flask:latest
	docker push $(DOCKERHUB_USERNAME)/hello-flask:latest

# Kubernetes
deploy:
	@echo "☸️  Deploying to Kubernetes..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

deploy-local:
	@echo "☸️  Deploying with local image..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml
	kubectl -n demo set image deployment/hello-flask hello-flask=hello-flask:local
	kubectl -n demo rollout status deployment/hello-flask

status:
	@echo "📊 Kubernetes Status:"
	kubectl get pods -n demo
	kubectl get services -n demo
	kubectl get deployments -n demo

logs:
	@echo "📋 Application Logs:"
	kubectl -n demo logs -l app=hello-flask --tail=50

port-forward:
	@echo "🌐 Starting port forward..."
	@echo "Application will be available at http://localhost:8081"
	kubectl -n demo port-forward svc/hello-flask 8081:80

# Jenkins
jenkins-start:
	@echo "🔧 Starting Jenkins..."
	docker compose up -d

jenkins-stop:
	@echo "🛑 Stopping Jenkins..."
	docker compose down

jenkins-logs:
	@echo "📋 Jenkins Logs:"
	docker compose logs jenkins

# Cleanup
clean:
	@echo "🧹 Cleaning up Kubernetes resources..."
	kubectl delete namespace demo --ignore-not-found=true
	@echo "🧹 Cleaning up Docker images..."
	docker rmi hello-flask:latest hello-flask:local --force 2>/dev/null || true

clean-all: clean
	@echo "🧹 Cleaning up everything..."
	docker compose down -v
	docker system prune -f
	@echo "🧹 Removing .env file..."
	rm -f .env
