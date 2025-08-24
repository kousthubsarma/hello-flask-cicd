# GitHub Webhook Setup Instructions

## Step 1: Add Webhook to GitHub Repository

1. Go to: https://github.com/kousthubsarma/hello-flask-cicd
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Configure webhook:
   - **Payload URL**: `http://localhost:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Secret**: (leave empty for local testing)
   - **Events**: Select **"Just the push event"**
4. Click **Add webhook**

## Step 2: Configure Jenkins Job

1. Go to: http://localhost:8080 (admin/admin123)
2. Click **New Item**
3. Enter **"hello-flask-cicd"** as name
4. Select **"Pipeline"** and click **OK**
5. In **Build Triggers** section:
   - Check **"GitHub hook trigger for GITScm polling"**
6. In **Pipeline** section:
   - Select **"Pipeline script from SCM"**
   - **SCM**: Select **Git**
   - **Repository URL**: `https://github.com/kousthubsarma/hello-flask-cicd.git`
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile.simple`
7. Click **Save**

## Step 3: Test the Webhook

After setup, any push to the main branch will automatically trigger the Jenkins pipeline!
