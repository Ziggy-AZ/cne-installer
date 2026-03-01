# Liferay Cloud Native - GCP Installer
Click the button below to start the guided setup in Google Cloud Shell.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/Ziggy-AZ/cne-installer&cloudshell_tutorial=tutorial.md&cloudshell_workspace=.&cloudshell_open_in_editor=terraform.tfvars)

## GitHub App Setup

If you'd like to use a GitHub App for SSO / GitHub repo access, you can use the [GitHub App Manifest Tool](https://ziggy-az.github.io/cne-installer/).

### Steps:
1. **Generate Manifest**: Enter your **GitHub Organization** and **ArgoCD Base URL** (e.g., `https://argocd.example.com`) into the tool.
2. **Register**: Click **Register GitHub App**. You will be redirected to GitHub to name and create the app.
3. **Install**: After creation, navigate to **Install App** in the GitHub App settings and install it on your organization.
4. **Retrieve Credentials**: Upon installation, you will be redirected to a success page. 
   - Note your **App ID** and **Installation ID**.
   - Download or copy the **Private Key** (PEM format).
5. **Store Secrets**: Run the following command in your Cloud Shell to securely store these credentials:
   ```bash
   ./setup-github-app-secret.sh <PROJECT_ID>
   ```