# Liferay Cloud Native - GCP Installer

Automated infrastructure for deploying Liferay DXP on Google Cloud Platform using GKE Autopilot, Crossplane, and ArgoCD.

## Documentation

Full documentation, architecture reports, and setup guides are available at:
**[https://ziggy-az.github.io/cne-installer/](https://ziggy-az.github.io/cne-installer/)**

## Quick Start

Click the button below to start the guided setup in Google Cloud Shell.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/Ziggy-AZ/cne-installer&cloudshell_tutorial=tutorial.md&cloudshell_workspace=.&cloudshell_open_in_editor=terraform.tfvars)

## GitHub App Setup

For SSO and GitOps repository access, please refer to the **[GitHub App Setup Guide](https://ziggy-az.github.io/cne-installer/#/github-app-setup)**.

## Security Validation

To ensure your infrastructure complies with corporate security standards, you can run Checkov locally before committing changes.

### 1. Install Checkov
```sh
pip install checkov
```

### 2. Run Local Scan
Execute the following command to scan your infrastructure code while ignoring temporary generated files and external modules:

```sh
checkov -d . \
    --framework terraform,kubernetes,helm,secrets \
    --skip-path state-credentials.tf \
    --skip-path .external_modules \
    --quiet-compact
```
