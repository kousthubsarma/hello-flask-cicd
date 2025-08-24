# 🚀 Complete Automated CI/CD Pipeline

A **fully automated CI/CD pipeline** that demonstrates end-to-end automation using Jenkins, Docker, Kubernetes, and GitHub. When you change the hello message in `app.py` and commit it, the application automatically updates on the port-forwarded URL!

## 🎯 **What This Demo Shows**

- ✅ **Complete Automation**: Change code → Commit → Push → Auto-build → Auto-deploy → Live update
- ✅ **Zero Downtime Deployments**: Rolling updates with Kubernetes
- ✅ **Full CI/CD Pipeline**: Test → Build → Push → Deploy → Smoke Test
- ✅ **Real-time Updates**: Changes appear on http://localhost:8081/ automatically
- ✅ **Production Ready**: Scalable, monitored, and robust

## 🚀 **Quick Start**

### **Prerequisites**
- Docker Desktop
- Minikube
- kubectl
- Git

### **One-Command Setup**
```bash
# Clone and setup
git clone https://github.com/kousthubsarma/hello-flask-cicd.git
cd hello-flask-cicd

# Start everything
./auto-setup.sh

# Access the application
kubectl port-forward -n demo svc/hello-flask 8081:80 &
curl http://localhost:8081/
```

## 🔄 **Complete Automated Workflow**

### **The Magic: Change → Commit → Live Update**

1. **Make a change** to `app.py`:
   ```python
   message="Hello, CI/CD with Flask - My New Message!",
   ```

2. **Commit and push**:
   ```bash
   git add app.py
   git commit -m "Update hello message"
   git push origin main
   ```

3. **Watch the automation**:
   - GitHub Actions builds and deploys automatically
   - Jenkins pipeline runs (if webhook configured)
   - New Docker image is built and pushed
   - Kubernetes deployment updates
   - Application shows new message on http://localhost:8081/

4. **Verify the update**:
   ```bash
   curl http://localhost:8081/
   # Shows: {"message":"Hello, CI/CD with Flask - My New Message!","timestamp":"unknown","version":"1.0.0"}
   ```

## 🌐 **Access Points**

### **Application**
- **URL**: http://localhost:8081/
- **Health Check**: http://localhost:8081/health
- **Port Forward**: `kubectl port-forward -n demo svc/hello-flask 8081:80`

### **Jenkins Dashboard**
- **URL**: http://localhost:8080
- **Username**: admin
- **Password**: admin123
- **Job**: hello-flask-cicd

### **Kubernetes Dashboard**
- **Command**: `minikube dashboard`
- **Namespace**: demo (change from default)

## 📊 **Pipeline Stages**

1. **Prep**: Configure kubectl and verify tools
2. **Install & Test**: Python environment setup and unit tests
3. **Build Image**: Docker image building
4. **Push Image**: Push to Docker Hub
5. **Deploy to K8s**: Kubernetes deployment with rolling updates
6. **Smoke Test**: Application health verification

## 🎮 **Demo Commands**

### **Test the Complete Automation**
```bash
# 1. Make a change
echo '        message="Hello, CI/CD with Flask - Demo at $(date)!"' >> app.py

# 2. Commit and push (triggers automation)
git add app.py
git commit -m "Test automatic update"
git push origin main

# 3. Watch the automation
# - Check GitHub Actions: https://github.com/kousthubsarma/hello-flask-cicd/actions
# - Check Jenkins: http://localhost:8080

# 4. Verify the update
curl http://localhost:8081/
```

### **Manual Commands (if needed)**
```bash
# Build and deploy manually
docker build -t kousthubsarma/hello-flask:latest .
docker push kousthubsarma/hello-flask:latest
kubectl rollout restart -n demo deploy/hello-flask

# Check status
kubectl get pods -n demo
kubectl get svc -n demo
kubectl logs -n demo deploy/hello-flask
```

## 🔧 **Configuration**

### **Automatic Triggers**
- **GitHub Actions**: Automatically triggered on push to main
- **Jenkins Webhook**: Configure webhook for local Jenkins automation
- **File Monitoring**: Triggers on changes to `app.py`, `requirements.txt`, `Dockerfile`, `k8s/**`

### **Kubernetes Resources**
- **Namespace**: demo
- **Deployment**: hello-flask (5 replicas)
- **Service**: ClusterIP on port 80
- **Health Checks**: Readiness and liveness probes

## 📈 **Monitoring & Debugging**

### **Check Pipeline Status**
```bash
# Jenkins logs
docker logs jenkins

# Kubernetes status
kubectl get pods -n demo
kubectl get events -n demo

# Application logs
kubectl logs -n demo deploy/hello-flask -f
```

### **Troubleshooting**
```bash
# Restart services
docker compose restart
minikube restart

# Reset deployment
kubectl rollout restart -n demo deploy/hello-flask

# Check connectivity
curl http://localhost:8081/health
```

## 🎯 **Success Indicators**

When everything is working correctly:
- ✅ **Git push** triggers automation
- ✅ **Docker image** builds successfully
- ✅ **Kubernetes deployment** updates with zero downtime
- ✅ **Application** shows new message on http://localhost:8081/
- ✅ **Health checks** pass: `{"status":"ok"}`

## 🚀 **Next Steps**

### **Production Enhancements**
1. **Add Monitoring**: Prometheus and Grafana
2. **Add Security**: Vulnerability scanning
3. **Add Notifications**: Slack/email alerts
4. **Add Rollback**: Automatic rollback on failures

### **Advanced Features**
1. **Blue-Green Deployment**: Zero-downtime deployments
2. **Canary Releases**: Gradual rollout strategy
3. **Feature Flags**: A/B testing capabilities
4. **Performance Testing**: Load testing integration

## 📚 **Learning Resources**

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Workflows](https://docs.github.com/en/actions/using-workflows)

## 🎉 **Congratulations!**

You now have a **complete, production-ready CI/CD pipeline** that automatically:
- ✅ **Builds** your application on code changes
- ✅ **Tests** your code for quality
- ✅ **Deploys** to Kubernetes with zero downtime
- ✅ **Updates** the live application automatically
- ✅ **Monitors** application health continuously

**Your CI/CD pipeline is fully automated and ready for production! 🚀**

---

**Happy CI/CD-ing! 🎉**
