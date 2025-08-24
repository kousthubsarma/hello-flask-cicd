# Jenkins Webhook Setup for Automatic Triggers

## Overview
This guide explains how to set up Jenkins to automatically trigger the CI/CD pipeline when changes are committed to the Git repository.

## Prerequisites
- Jenkins server running (http://localhost:8080)
- GitHub repository with webhook access
- Jenkins job already created (`hello-flask-cicd`)

## Step 1: Install Required Jenkins Plugins

1. Go to **Jenkins Dashboard** → **Manage Jenkins** → **Manage Plugins**
2. Install these plugins:
   - **GitHub Integration**
   - **GitHub API Plugin**
   - **GitHub Branch Source**
   - **Pipeline: GitHub**

## Step 2: Configure GitHub Integration

1. Go to **Jenkins Dashboard** → **Manage Jenkins** → **Configure System**
2. Find **GitHub** section
3. Add GitHub Server:
   - **Name**: `GitHub`
   - **API URL**: `https://api.github.com`
   - **Credentials**: Add your GitHub credentials
4. **Test connection** to verify

## Step 3: Update Jenkins Job Configuration

1. Go to your **hello-flask-cicd** job
2. Click **Configure**
3. In **Build Triggers** section:
   - Check **"GitHub hook trigger for GITScm polling"**
4. In **Pipeline** section:
   - Change from **"Pipeline script"** to **"Pipeline script from SCM"**
   - **SCM**: Select **Git**
   - **Repository URL**: `https://github.com/kousthubsarma/hello-flask-cicd.git`
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile.simple`
5. Click **Save**

## Step 4: Configure GitHub Webhook

1. Go to your GitHub repository: https://github.com/kousthubsarma/hello-flask-cicd
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Configure webhook:
   - **Payload URL**: `http://localhost:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Secret**: (leave empty for local testing)
   - **Events**: Select **"Just the push event"**
4. Click **Add webhook**

## Step 5: Test the Webhook

1. Make a change to `app.py`:
   ```bash
   echo "# Webhook test at $(date)" >> app.py
   ```

2. Commit and push:
   ```bash
   git add app.py
   git commit -m "Test webhook trigger"
   git push origin main
   ```

3. Check Jenkins:
   - Go to http://localhost:8080
   - You should see the job automatically triggered
   - Check the build logs

## Alternative: GitHub Actions (Recommended)

For a cloud-based solution, use the GitHub Actions workflow in `.github/workflows/ci-cd.yml`:

1. **Push to main branch** automatically triggers the workflow
2. **Runs tests** on every push
3. **Builds and pushes Docker image** on main branch
4. **Deploys to Kubernetes** (configure for your cluster)

## Troubleshooting

### Webhook Not Triggering
- Check Jenkins logs: `docker logs jenkins`
- Verify webhook URL is accessible
- Check GitHub webhook delivery logs

### Jenkins Job Not Starting
- Verify GitHub integration is configured
- Check job configuration for SCM settings
- Ensure Jenkinsfile.simple exists in repository

### Permission Issues
- Make sure Jenkins has access to the repository
- Check GitHub credentials in Jenkins
- Verify webhook permissions

## Security Considerations

- Use HTTPS for webhook URLs in production
- Add webhook secrets for security
- Use GitHub App instead of personal access tokens
- Restrict webhook to specific events and branches
