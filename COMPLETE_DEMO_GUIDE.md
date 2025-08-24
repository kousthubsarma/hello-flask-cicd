# 🎯 Complete Automated CI/CD Demo Guide

## 🎉 **The Magic: Change Code → Live Update**

This guide demonstrates the **complete automated CI/CD pipeline** where changing the hello message in `app.py` automatically updates the live application on http://localhost:8081/.

## 🚀 **Prerequisites**

✅ **Infrastructure Running**:
- Minikube: `minikube start --driver=docker`
- Jenkins: `docker compose up -d`
- Application: Deployed and accessible

✅ **Port Forward Active**:
```bash
kubectl port-forward -n demo svc/hello-flask 8081:80 &
```

## 🎯 **Step-by-Step Demo**

### **Step 1: Verify Current State**

Check the current application:
```bash
curl http://localhost:8081/
```

**Expected Output**:
```json
{"message":"Hello, CI/CD with Flask - Fully Automatic Demo!","timestamp":"unknown","version":"1.0.0"}
```

### **Step 2: Make a Change**

Edit the hello message in `app.py`:
```bash
# Change the message
sed -i '' 's/Fully Automatic Demo!/Live Demo Test!/' app.py

# Verify the change
grep -n "Hello," app.py
```

**Expected Output**:
```
14:        message="Hello, CI/CD with Flask - Live Demo Test!",
```

### **Step 3: Commit and Push (Triggers Automation)**

```bash
git add app.py
git commit -m "Demo: Change hello message to test automation"
git push origin main
```

**What happens automatically**:
1. ✅ **GitHub Actions** triggers (cloud-based)
2. ✅ **Jenkins Pipeline** triggers (if webhook configured)
3. ✅ **Docker Image** builds with new code
4. ✅ **Image Pushes** to Docker Hub
5. ✅ **Kubernetes Deployment** updates
6. ✅ **Application** shows new message

### **Step 4: Monitor the Automation**

#### **Option A: GitHub Actions (Recommended)**
- Go to: https://github.com/kousthubsarma/hello-flask-cicd/actions
- Watch the workflow run through all stages

#### **Option B: Jenkins (Local)**
- Go to: http://localhost:8080 (admin/admin123)
- Navigate to: hello-flask-cicd job
- Watch the build progress

#### **Option C: Command Line**
```bash
# Watch Kubernetes deployment
kubectl rollout status -n demo deploy/hello-flask

# Check new pods
kubectl get pods -n demo

# Check application logs
kubectl logs -n demo deploy/hello-flask -f
```

### **Step 5: Verify the Update**

Wait for the deployment to complete, then check the application:
```bash
curl http://localhost:8081/
```

**Expected Output**:
```json
{"message":"Hello, CI/CD with Flask - Live Demo Test!","timestamp":"unknown","version":"1.0.0"}
```

## 🎮 **Interactive Demo Commands**

### **Quick Test Commands**
```bash
# 1. Make a quick change
echo '        message="Hello, CI/CD with Flask - Quick Test at $(date)!"' >> app.py

# 2. Commit and push
git add app.py && git commit -m "Quick test" && git push origin main

# 3. Watch the magic happen
# - Check GitHub Actions: https://github.com/kousthubsarma/hello-flask-cicd/actions
# - Wait 2-3 minutes for deployment

# 4. Verify the update
curl http://localhost:8081/
```

### **Multiple Changes Demo**
```bash
# Make several changes in sequence
for i in {1..3}; do
  echo "        message=\"Hello, CI/CD with Flask - Test $i at $(date)!\"" >> app.py
  git add app.py && git commit -m "Test $i" && git push origin main
  echo "Pushed test $i - waiting for deployment..."
  sleep 30
  curl http://localhost:8081/
  echo -e "\n---\n"
done
```

## 📊 **Monitoring the Pipeline**

### **Check Pipeline Status**
```bash
# GitHub Actions status
echo "GitHub Actions: https://github.com/kousthubsarma/hello-flask-cicd/actions"

# Jenkins status
echo "Jenkins: http://localhost:8080"

# Kubernetes status
kubectl get pods -n demo
kubectl get deploy -n demo
kubectl get events -n demo --sort-by='.lastTimestamp'
```

### **Application Health**
```bash
# Health check
curl http://localhost:8081/health

# Main application
curl http://localhost:8081/

# Application logs
kubectl logs -n demo deploy/hello-flask -f
```

## 🔧 **Troubleshooting**

### **If Automation Doesn't Work**

#### **Manual Build and Deploy**
```bash
# Build new image
docker build -t kousthubsarma/hello-flask:latest .

# Push to Docker Hub
docker push kousthubsarma/hello-flask:latest

# Deploy to Kubernetes
kubectl rollout restart -n demo deploy/hello-flask

# Wait for deployment
kubectl rollout status -n demo deploy/hello-flask

# Test the application
curl http://localhost:8081/
```

#### **Check Infrastructure**
```bash
# Check if services are running
docker ps | grep jenkins
minikube status

# Restart if needed
docker compose restart
minikube restart
```

### **Common Issues**

#### **Port Forward Disconnected**
```bash
# Kill existing port-forward
pkill -f "kubectl port-forward"

# Start new port-forward
kubectl port-forward -n demo svc/hello-flask 8081:80 &
```

#### **Application Not Updating**
```bash
# Force pull new image
kubectl rollout restart -n demo deploy/hello-flask

# Check image being used
kubectl get pods -n demo -o jsonpath='{.items[*].spec.containers[*].image}'
```

## 🎯 **Success Indicators**

When the automation is working correctly:

✅ **Git Push** → **GitHub Actions** → **Build Success** → **Deploy Success** → **Live Update**

You should see:
- ✅ New Docker image built and pushed
- ✅ Kubernetes deployment updated
- ✅ New pods running with updated image
- ✅ Application showing new message on http://localhost:8081/
- ✅ Health checks passing: `{"status":"ok"}`

## 🚀 **Advanced Demo Scenarios**

### **Scenario 1: Multiple Rapid Changes**
```bash
# Make changes every 30 seconds
for i in {1..5}; do
  echo "        message=\"Rapid Test $i at $(date)!\"" >> app.py
  git add app.py && git commit -m "Rapid test $i" && git push origin main
  sleep 30
done
```

### **Scenario 2: Scale and Update**
```bash
# Scale the application
kubectl scale -n demo deploy/hello-flask --replicas=10

# Make a change
echo "        message=\"Scaled Demo at $(date)!\"" >> app.py
git add app.py && git commit -m "Scale demo" && git push origin main

# Watch all replicas update
kubectl get pods -n demo -w
```

### **Scenario 3: Rollback Test**
```bash
# Make a change
echo "        message=\"Rollback Test at $(date)!\"" >> app.py
git add app.py && git commit -m "Rollback test" && git push origin main

# Wait for deployment, then rollback
kubectl rollout undo -n demo deploy/hello-flask
kubectl rollout status -n demo deploy/hello-flask

# Check the rollback
curl http://localhost:8081/
```

## 🎉 **Demo Complete!**

You've successfully demonstrated a **complete automated CI/CD pipeline** where:

1. ✅ **Code changes** trigger automation
2. ✅ **Builds** happen automatically
3. ✅ **Deployments** occur with zero downtime
4. ✅ **Applications** update live
5. ✅ **Health** is monitored continuously

**Your CI/CD pipeline is production-ready! 🚀**

---

**Next**: Set up GitHub webhooks for Jenkins to make the automation even more seamless!
