# GCP Infrastructure Setup Guide

This document outlines the required manual steps and permissions needed in Google Cloud Platform (GCP) before running any Terraform or OpenTofu scripts.

## 1. Prerequisites

- **GCP Project:** A dedicated GCP project must be created.
- **Billing:** Billing must be enabled for the project to provision resources (GKE, Cloud SQL, etc.).
- **gcloud SDK:** The `gcloud` CLI must be installed and authenticated.
  ```bash
  gcloud auth login
  gcloud auth application-default login
  ```

## 2. Essential APIs

The following APIs must be enabled for the infrastructure to provision correctly. While Terraform attempts to enable these, the identity running Terraform must have `serviceusage.serviceUsageAdmin` to do so.

| API Name | Purpose |
| :--- | :--- |
| `artifactregistry.googleapis.com` | Docker & Helm Chart Storage |
| `cloudbuild.googleapis.com` | CI/CD and Image Building |
| `cloudresourcemanager.googleapis.com` | Project & IAM Management |
| `compute.googleapis.com` | VPC, Firewall, Routers, Load Balancers |
| `config.googleapis.com` | Infrastructure Manager (for Blueprints) |
| `connectgateway.googleapis.com` | GKE Fleet Management |
| `container.googleapis.com` | GKE Cluster Provisioning |
| `gkehub.googleapis.com` | Fleet Registration & Connect Gateway |
| `iam.googleapis.com` | Service Accounts & IAM Policies |
| `iamcredentials.googleapis.com` | Token generation & Impersonation |
| `secretmanager.googleapis.com` | Sensitive Data Storage (Keys, Tokens) |
| `servicemanagement.googleapis.com` | Service Configuration |
| `servicenetworking.googleapis.com` | Private VPC Peering (for Cloud SQL) |
| `sqladmin.googleapis.com` | Cloud SQL Management |
| `storage-api.googleapis.com` | GCS Bucket access |
| `sts.googleapis.com` | Security Token Service (Workload Identity) |

**Manual Enablement:**
```bash
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  gkehub.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  secretmanager.googleapis.com \
  servicenetworking.googleapis.com \
  sqladmin.googleapis.com \
  sts.googleapis.com
```

---

## 3. Required IAM Roles

The identity (User or Service Account) running the Terraform scripts requires the following roles at the **Project Level**.

### For Administrative Setup (Bootstrap)
If you are running the initial bootstrap from your local machine, your user requires:
- `roles/owner` (Simplest for initial setup)
- **OR** the specific Admin roles listed below.

### For Spacelift Runner / Terraform Service Account
The `spacelift-runner` service account requires these specific roles to manage the lifecycle of all resources:

- `roles/artifactregistry.admin`
- `roles/cloudsql.admin`
- `roles/compute.admin`
- `roles/config.admin`
- `roles/container.admin`
- `roles/gkehub.admin` (Required for Connect Gateway)
- `roles/iam.serviceAccountAdmin`
- `roles/iam.serviceAccountUser`
- `roles/iam.workloadIdentityPoolAdmin`
- `roles/logging.logWriter`
- `roles/monitoring.metricWriter`
- `roles/resourcemanager.projectIamAdmin` (Required to bind KSA to GSA)
- `roles/secretmanager.admin`
- `roles/servicenetworking.networksAdmin`
- `roles/serviceusage.serviceUsageAdmin`
- `roles/storage.admin`

---

## 4. Automated Setup Scripts

The `cne-installer` repository provides scripts to automate most of this setup.

### A. Spacelift & Workload Identity
This script enables APIs, creates the runner Service Account, grants all necessary roles, and configures Workload Identity Federation (WIF).
```bash
./setup-spacelift.sh <PROJECT_ID> <SPACELIFT_HOSTNAME> <SPACELIFT_SPACE_ID> <SPACELIFT_SA_EMAIL>
```

### B. Secret Management
Before running the GitOps or Platform Terraform, ensure required secrets exist in Secret Manager.
```bash
./setup-secret.sh <PROJECT_ID> <SECRET_NAME> <SECRET_VALUE>
```
*Required secrets typically include: `cloudflare-api-token`, `github-app-private-key`, `github-webhook-secret`.*

---

## 5. Network Requirements

When configuring the Terraform variables, ensure the following CIDR ranges are planned and do not overlap with existing corporate networks if peering is required:

- **VPC CIDR:** `10.0.0.0/16` (Default - Pod and Service ranges are automatically calculated from this block)
- **GKE Master IPv4 CIDR:** `172.16.0.0/28` (Used for Private Cluster peering - customizable via `master_ipv4_cidr_block` variable)
