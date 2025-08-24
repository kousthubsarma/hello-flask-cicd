# Local CI/CD Pipeline Setup Guide

A comprehensive guide for setting up a complete **local-only** CI/CD pipeline using Jenkins, Docker, and Kubernetes (Minikube).

## 🎯 **Overview**

This guide will help you set up a fully functional CI/CD pipeline that demonstrates:

- **Jenkins Pipeline**: Building from local workspace
- **Docker Containerization**: Building and pushing images
- **Kubernetes Orchestration**: Deploying to local Minikube
- **Automated Testing**: Unit tests and smoke tests
- **Health Monitoring**: Application health checks
- **Scaling**: Kubernetes deployment scaling

## 📋 **Prerequisites**

### Required Software
- **Docker Desktop**: For containerization and Jenkins
- **Minikube**: For local Kubernetes cluster
- **kubectl**: Kubernetes command-line tool
- **Git**: For version control (optional for local demo)

### Installation Instructions

#### macOS
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install docker docker-compose minikube kubernetes-cli git

# Install Docker Desktop
brew install --cask docker
```

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install Docker
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

# Install kubectl
sudo apt install -y kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Git
sudo apt install -y git
```

#### Windows
```bash
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install docker-desktop minikube kubernetes-cli git
```

## 🚀 **Quick Setup**

### Option 1: Automated Setup (Recommended)
```bash
# Clone the repository
git clone <your-repo-url>
cd cicd

# Run the automated setup
./auto-setup.sh
```

### Option 2: Manual Setup
Follow the step-by-step instructions below.

## 🔧 **Step-by-Step Setup**

### Step 1: Start Minikube
```bash
# Start Minikube with Docker driver
minikube start --driver=docker

# Verify Minikube is running
minikube status

# Check kubectl access
kubectl get nodes
```

### Step 2: Build Jenkins Image
```bash
# Build the custom Jenkins image
docker build -t cicd-jenkins:latest -f Dockerfile.jenkins .

# Verify the image was created
docker images | grep cicd-jenkins
```

### Step 3: Start Jenkins
```bash
# Start Jenkins with Docker Compose
docker compose up -d

# Wait for Jenkins to start (30 seconds)
sleep 30

# Check Jenkins logs
docker logs jenkins

# Verify Jenkins is accessible
curl -s http://localhost:8080/ | grep -q "Jenkins" && echo "Jenkins is running"
```

### Step 4: Access Jenkins
1. Open your browser and go to: http://localhost:8080
2. Login with:
   - **Username**: admin
   - **Password**: admin123

### Step 5: Create Jenkins Pipeline Job
1. Click **"New Item"** in Jenkins
2. Enter **"hello-flask-cicd"** as the job name
3. Select **"Pipeline"** and click **"OK"**
4. In the Pipeline section:
   - Select **"Pipeline script"** (NOT "Pipeline script from SCM")
   - Copy and paste the contents of `Jenkinsfile.simple` into the script area
5. Click **"Save"**

### Step 6: Run the Pipeline
1. Go to the **"hello-flask-cicd"** job
2. Click **"Build Now"**
3. Click on the build number to view the Console Output
4. Watch the pipeline stages execute

## 📁 **Project Structure**

```
cicd/
├── app.py                 # Flask application
├── Dockerfile            # Application container
├── Dockerfile.jenkins    # Jenkins container with tools
├── docker-compose.yml    # Jenkins orchestration
├── Jenkinsfile.simple    # Pipeline definition
├── k8s/                  # Kubernetes manifests
│   ├── namespace.yaml    # Demo namespace
│   ├── deployment.yaml   # Application deployment
│   └── service.yaml      # Service definition
├── tests/                # Unit tests
│   └── test_app.py       # Application tests
├── jenkins-casc/         # Jenkins Configuration as Code
│   └── jenkins.yaml      # Jenkins system configuration
├── auto-setup.sh         # Automated setup script
├── demo.sh              # Demo script
└── README.md            # Project documentation
```

## 🔄 **CI/CD Pipeline Stages**

The pipeline consists of the following stages:

### 1. Prep Stage
- Configure kubectl for container access
- Verify Python and kubectl availability
- Display workspace information

### 2. Install & Test Stage
- Set up Python virtual environment
- Install application dependencies
- Run unit tests with pytest

### 3. Build Image Stage
- Build Docker image from application
- Tag with latest version

### 4. Push Image Stage
- Push image to Docker Hub (optional)
- Requires Docker Hub login

### 5. Deploy to K8s Stage
- Apply Kubernetes manifests
- Deploy to demo namespace
- Wait for rollout completion

### 6. Smoke Test Stage
- Test application health endpoint
- Verify application is responding
- Clean up port-forward

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

## 🌐 **Access Points**

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

## 🔍 **Troubleshooting**

### Jenkins Issues
```bash
# Check if Jenkins is running
docker ps | grep jenkins

# Check Jenkins logs
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

### Application Issues
```bash
# Check pod status
kubectl get pods -n demo

# Check pod logs
kubectl logs -n demo deploy/hello-flask

# Check service
kubectl get svc -n demo

# Check events
kubectl get events -n demo
```

### Pipeline Issues
```bash
# Check Jenkins workspace
docker exec jenkins ls -la /workspace

# Check kubectl configuration in Jenkins
docker exec jenkins kubectl config view

# Check Docker access in Jenkins
docker exec jenkins docker ps
```

## 🧹 **Cleanup**

### Stop Services
```bash
# Stop Jenkins
docker compose down

# Stop Minikube
minikube stop
```

### Remove Resources
```bash
# Delete Kubernetes resources
kubectl delete namespace demo

# Remove Docker images
docker rmi cicd-jenkins:latest
docker rmi kousthubsarma/hello-flask:latest
```

### Complete Cleanup
```bash
# Stop everything
docker compose down
minikube stop

# Remove all resources
kubectl delete namespace demo --ignore-not-found=true
docker system prune -f
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

## 🤝 **Support**

If you encounter issues:

1. Check the troubleshooting section above
2. Review the logs and error messages
3. Ensure all prerequisites are installed
4. Verify network connectivity
5. Check Docker and Minikube status

## 📄 **Next Steps**

After completing this setup, you can:

1. **Enhance the Pipeline**: Add more stages like security scanning
2. **Add Monitoring**: Integrate Prometheus and Grafana
3. **Improve Testing**: Add integration and end-to-end tests
4. **Production Setup**: Deploy to a production Kubernetes cluster
5. **Git Integration**: Add webhooks for automatic builds

---

**Happy CI/CD-ing! 🚀**
