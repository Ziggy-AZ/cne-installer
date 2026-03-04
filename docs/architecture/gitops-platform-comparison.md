# GitOps Platform Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) and Amazon Web Services (AWS) GitOps platform (ArgoCD and bootstrap) implementations for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation | AWS Implementation |
| :--- | :--- | :--- |
| **ArgoCD Version** | `9.4.4` (Chart Version) | `9.1.5` (Chart Version) |
| **Namespace** | `argo-cd` (Managed via `kubernetes_namespace`) | `argocd` (Managed via `kubernetes_namespace`) |
| **Authentication** | **SSO Support:** Optional SSO module for OIDC/SAML. | **Default:** Standard ArgoCD local auth (with KMS secret management). |
| **UI Enhancements** | **Argo CD UI Tools:** Optional module for additional platform tools. | **Standard:** Standard ArgoCD UI. |
| **Health Checks** | Custom Lua health check for `LiferayInfrastructure` (GCP-flavored). | Custom Lua health check for `LiferayInfrastructure` (AWS-flavored). |
| **Resource Tracking** | `annotation` tracking method. | `annotation` tracking method. |
| **Secret Management** | **Secret Manager:** Integrates with Google Secret Manager for webhook and SSO secrets. | **KMS/Secret:** Standard Kubernetes secrets (with lifecycle protection). |
| **Network Access** | **Gateway API:** Explicit `HTTPRoute` for ArgoCD UI access. | **Ingress:** Typically uses standard Ingress or internal ALB (not shown in basic `argocd.tf`). |

## 2. Key Differences & Observations

### 2.1 Feature Richness
The **GCP Implementation** in `cloud/terraform/gcp/gitops/platform` is significantly more feature-rich. It includes optional modules for **SSO (Single Sign-On)** and **Argo CD UI Tools**, providing a more production-ready platform experience out-of-the-box.

The **AWS Implementation** is more focused on the core ArgoCD installation. While robust, it lacks the integrated SSO and UI tool support seen in the GCP version.

### 2.2 Network Strategy
GCP leverages the modern **Gateway API** (`HTTPRoute`) for exposing the ArgoCD service. This aligns with the overall platform strategy to use Gateway API for all ingress management. AWS typically relies on the more traditional Ingress controller or ALB integration.

### 2.3 Secret Management
GCP's use of `google_secret_manager_secret_version` for sensitive information like GitHub webhooks and SSO client secrets is more secure than managing them directly within Terraform or as plain Kubernetes secrets.

## 3. Recommendations for GCP Harmonization
1.  **ArgoCD Version:** Ensure both platforms are aligned on the same ArgoCD chart version (preferably the newer `9.4.4` used in GCP) to ensure feature parity and security.
2.  **Naming Convention:** Standardize the ArgoCD namespace (GCP uses `argo-cd`, AWS uses `argocd`) to simplify cross-platform scripts and documentation.
3.  **UI/SSO Alignment:** Propose the adoption of the SSO and UI tools modules for the AWS platform to provide a consistent administrative experience across clouds.
