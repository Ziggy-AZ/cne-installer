# Terraform Configuration Comparison: GCP vs. AWS

This document compares the configurability and configuration surface of the GCP implementation versus the AWS implementation of the Liferay Cloud Native Enterprise (CNE) installer.

## Executive Summary

The **GCP implementation** provides a more flexible and granular configuration for the **Kubernetes (GKE) layer** and **GitOps platform**, with deep integration for modern connectivity (Cloudflare, Netbird) and security (Kyverno). It relies on **Crossplane** for managed services, which simplifies the Terraform surface but shifts service configuration to the GitOps layer.

The **AWS implementation** is significantly more mature in **Data Management and Lifecycle**, offering dedicated modules for **Backups**, **Restore Workflows**, and **Blue/Green database slot management**. However, its core EKS configuration is less flexible through Terraform variables compared to the GCP counterpart.

| Area | Most Flexible Implementation | Major Gaps |
| :--- | :--- | :--- |
| **Compute/Cluster** | GCP | AWS EKS variables are minimal; GCP has better CIDR/Zone control. |
| **Managed Services** | AWS (Terraform-native) | GCP uses Crossplane (Service config is not in Terraform). |
| **Platform / GitOps** | GCP | AWS lacks native GitHub App auth support in GitOps variables. |
| **Data Lifecycle** | AWS | GCP lacks integrated Backup/Restore Terraform modules. |

## High-Level Stats

| Module / Functional Area | GCP Variable Count | AWS Variable Count | Primary Difference |
| :--- | :---: | :---: | :--- |
| Cluster Management (GKE/EKS) | 17 | 9 | GCP offers more networking and authorized network config. |
| Artifact Registry (GAR/ECR) | 6 | 3 | GCP supports KMS and public access toggles. |
| GitOps Platform | 11 | 4 | GCP includes detailed ArgoCD Auth/RBAC and Webhook config. |
| GitOps Resources | 18 | 17 | GCP adds support for GitHub App authentication. |
| Managed Services (SQL/Storage) | 0* | 9 | AWS uses Terraform modules; GCP uses Crossplane. |
| Backup & Recovery | 0 | 20 | AWS has comprehensive Backup Vault/Plan/Restore modules. |
| Connectivity (CF/Netbird) | 7 | 0 | GCP has first-class integration for these providers. |
| Security & Policy (Kyverno) | 5 | 0 | GCP manages Kyverno policies via Terraform. |

*\*GCP manages services via Crossplane; configuration exists in Helm/K8s manifests rather than Terraform variables.*

## Functional Breakdown

### Compute/Cluster Management
The GCP implementation allows for much finer control over the GKE environment directly from Terraform:
*   **Networking**: GCP exposes `pod_cidr`, `service_cidr`, and `authorized_ipv4_cidr_block`. AWS EKS assumes existing subnets or uses a simpler `vpc_cidr` approach.
*   **Zones**: GCP allows explicitly defining `node_zones` for cluster spread.
*   **Features**: GCP integrates `demo_mode` and `networking_mode` (Gateway vs. Ingress) as top-level variables.

### Managed Services (SQL, Search, Storage)
There is a fundamental architectural difference in how managed services are configured:
*   **AWS**: Uses traditional Terraform modules (`db-instance`, `s3-bucket`). This makes the infrastructure surface visible in Terraform but couples service lifecycle to the Terraform run.
*   **GCP**: Uses **Crossplane**. There are no Terraform variables for Cloud SQL or GCS because these resources are declared as Kubernetes manifests. This provides better "Day 2" management via GitOps but reduces visibility in the initial Terraform plan.

### Platform (ArgoCD, Add-ons)
*   **Authentication**: GCP provides a structured `argo_cd_auth_config` object, supporting OIDC and RBAC. It also uniquely supports **GitHub App** authentication for GitOps repositories.
*   **Add-ons**: GCP includes variables for **Kyverno**, **Cloudflare**, and **Netbird**, which are missing from the AWS Terraform surface.

### Backup and Data Lifecycle
AWS is the clear leader in this category:
*   **Backup**: Dedicated modules for `backup-vault`, `backup-plan`, and `backup-selection`.
*   **Recovery**: A specialized `backup-restore-workflow` module using Argo Workflows.
*   **Blue/Green**: The `dependencies` module includes `data_active` (blue/green) logic for database migrations.

## Harmonization TODO

To achieve parity between the two implementations, the following gaps should be addressed:

### Add to GCP (from AWS)
1.  **Backup/Restore**: Implement GKE Backup/Restore modules or Velero integration in Terraform.
2.  **Blue/Green Slots**: Add `data_active` slot management to the dependencies/resources modules.
3.  **Tags**: Standardize `tags` variable usage across all modules (AWS uses this extensively for billing and backup selection).

### Add to AWS (from GCP)
1.  **Networking Flexibility**: Expose more granular CIDR and authorized network configuration in the EKS module.
2.  **GitHub App Support**: Update GitOps resource modules to support GitHub App authentication.
3.  **Integrated Connectivity**: Add modules/variables for Cloudflare Zero Trust and Netbird integration.
4.  **Security Policy**: Add Kyverno (or AWS equivalent like OPA/Gatekeeper) configuration to the platform layer.
