# Local CI/CD Pipeline Demo

A complete **local-only** CI/CD pipeline demonstrating Jenkins, Docker, and Kubernetes integration without requiring GitHub or external services.

## 🎯 **What This Demo Shows**

- **Jenkins Pipeline**: Building from local workspace
- **Docker Containerization**: Building and pushing images
- **Kubernetes Orchestration**: Deploying to local Minikube
- **Automated Testing**: Unit tests and smoke tests
- **Health Monitoring**: Application health checks
- **Scaling**: Kubernetes deployment scaling

## 🚀 **Quick Start**

### Prerequisites
- Docker Desktop
- Minikube
- kubectl

### One-Command Setup
```bash
# Clone and setup
git clone <your-repo>
cd cicd

# Start everything
./auto-setup.sh
```

### Manual Setup
```bash
# 1. Start Minikube
minikube start --driver=docker

# 2. Start Jenkins
docker compose up -d

# 3. Wait for Jenkins (30 seconds)
sleep 30

# 4. Access Jenkins
# Open: http://localhost:8080 (admin/admin123)
```

## 📋 **Pipeline Overview**

The CI/CD pipeline consists of these stages:

1. **Prep**: Configure kubectl and verify tools
2. **Install & Test**: Python environment setup and unit tests
3. **Build Image**: Docker image building
4. **Push Image**: Push to Docker Hub (optional)
5. **Deploy to K8s**: Kubernetes deployment
6. **Smoke Test**: Application health verification

## 🔧 **Access Points**

### Jenkins Dashboard
- **URL**: http://localhost:8080
- **Credentials**: admin/admin123
- **Job**: hello-flask-cicd

### Application
- **Health Check**: http://localhost:8081/health
- **Main App**: http://localhost:8081/
- **Port Forward**: `kubectl port-forward -n demo svc/hello-flask 8081:80`

### Kubernetes Dashboard
- **Command**: `minikube dashboard`
- **Namespace**: Change to "demo" to see your resources

## 📁 **Project Structure**

```
cicd/
├── app.py                 # Flask application
├── Dockerfile            # Application container
├── Dockerfile.jenkins    # Jenkins container with tools
├── docker-compose.yml    # Jenkins orchestration
├── Jenkinsfile.simple    # Pipeline definition
├── k8s/                  # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── tests/                # Unit tests
├── jenkins-casc/         # Jenkins Configuration as Code
├── auto-setup.sh         # Automated setup script
└── README.md            # This file
```

## 🎮 **Demo Commands**

### Start Everything
```bash
# Start Minikube
minikube start --driver=docker

# Start Jenkins
docker compose up -d

# Wait for Jenkins
sleep 30
```

### Run Pipeline
1. Open http://localhost:8080 (admin/admin123)
2. Go to "hello-flask-cicd" job
3. Click "Build Now"
4. Watch Console Output

### Verify Deployment
```bash
# Check resources
kubectl get pods -n demo
kubectl get svc -n demo
kubectl get deploy -n demo

# Test application
kubectl port-forward -n demo svc/hello-flask 8081:80 &
curl http://localhost:8081/health
curl http://localhost:8081/
```

### Scale Application
```bash
# Scale up
kubectl scale -n demo deploy/hello-flask --replicas=5

# Scale down
kubectl scale -n demo deploy/hello-flask --replicas=1
```

### Make Changes
```bash
# Edit application
echo "# Updated at $(date)" >> app.py

# Re-run pipeline in Jenkins
# Go to Jenkins → hello-flask-cicd → Build Now
```

## 🧹 **Cleanup**

```bash
# Stop Jenkins
docker compose down

# Stop Minikube
minikube stop

# Remove resources
kubectl delete namespace demo
```

## 🔍 **Troubleshooting**

### Jenkins Not Accessible
```bash
# Check if Jenkins is running
docker ps | grep jenkins

# Check logs
docker logs jenkins

# Restart Jenkins
docker compose down && docker compose up -d
```

### Kubernetes Issues
```bash
# Check Minikube status
minikube status

# Restart Minikube
minikube stop && minikube start --driver=docker

# Check kubectl access
kubectl get nodes
```

### Application Not Responding
```bash
# Check pod status
kubectl get pods -n demo

# Check pod logs
kubectl logs -n demo deploy/hello-flask

# Check service
kubectl get svc -n demo
```

## 🎉 **Success Indicators**

When everything is working correctly, you should see:

- ✅ **Jenkins**: Pipeline completed with SUCCESS
- ✅ **Application**: Responding on http://localhost:8081
- ✅ **Kubernetes**: Pod running in demo namespace
- ✅ **Dashboard**: Resources visible in demo namespace
- ✅ **Health Check**: `{"status":"ok"}`

## 📚 **Learning Resources**

- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)

## 🤝 **Contributing**

This is a demo project. Feel free to:
- Add more test cases
- Enhance the pipeline stages
- Improve the application features
- Add monitoring and logging

## 📄 **License**

This project is for educational purposes. Use it to learn about CI/CD pipelines, containerization, and Kubernetes orchestration.

---

**Happy CI/CD-ing! 🚀**
