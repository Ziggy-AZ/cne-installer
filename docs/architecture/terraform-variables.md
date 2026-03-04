# GCP Terraform Variables Reference

This document provides a comprehensive reference for all Terraform variables used in the GCP implementation of the Liferay Cloud Native Enterprise (CNE) installer.

## Table of Contents
1. [Artifact Registry (GAR)](#artifact-registry-gar)
2. [GKE Cluster (Core)](#gke-cluster-core)
3. [GKE Add-ons](#gke-add-ons)
4. [Security & Policy (Kyverno)](#security--policy-verno)
5. [GitOps Platform](#gitops-platform)
6. [GitOps Resources](#gitops-resources)

---

## Artifact Registry (GAR)
**Location:** `cloud/terraform/gcp/gar/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `deployment_name` | `string` | `"liferay-gcp"` | N/A |
| `region` | `string` | Required | N/A |
| `project_id` | `string` | Required | The GCP Project ID |
| `kms_key_name` | `string` | `null` | The Cloud KMS key name to encrypt the repository. If not provided and create_kms_key is false, Google-managed keys will be used. |
| `create_kms_key` | `bool` | `false` | Whether to create a new Cloud KMS key for the repository. If true, kms_key_name will be ignored. |
| `enable_public_gar_access` | `bool` | `false` | Whether to make the Artifact Registry repository public (allUsers). |

## GKE Cluster (Core)
**Location:** `cloud/terraform/gcp/gke/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `authorized_ipv4_cidr_block` | `string` | `""` | The CIDR block for GKE Master Authorized Networks. If empty, authorized networks will be disabled. |
| `cloudflare_account_id` | `string` | `""` | N/A |
| `cloudflare_zone_id` | `string` | `""` | N/A |
| `demo_mode` | `bool` | `false` | N/A |
| `deployment_name` | `string` | `"liferay-gcp"` | N/A |
| `deployment_namespace` | `string` | `"liferay-system"` | N/A |
| `domains` | `list(string)` | `[]` | List of root domains to support. If empty, the cluster will be created without custom domain routing. |
| `ecr_repositories` | `map(object({ arn=string, url=string }))` | `{}` | Kept for compatibility, though usually unused in GCP if using Artifact Registry in the same project. |
| `enable_cloudflare` | `bool` | `false` | Whether to enable Cloudflare Zero Trust Tunnel and DNS management. |
| `enable_netbird` | `bool` | `false` | Whether to enable NetBird Reverse Proxy. |
| `networking_mode` | `string` | `"gateway"` | Set to 'ingress' for legacy NGINX or 'gateway' for modern Envoy. |
| `node_zones` | `list(string)` | `[]` | The zones where the GKE cluster nodes should be located. If empty, the cluster will be spread across all zones in the region. |
| `pod_cidr` | `string` | `"10.1.0.0/16"` | N/A |
| `project_id` | `string` | Required | The GCP Project ID |
| `region` | `string` | `"us-central1"` | N/A |
| `service_cidr` | `string` | `"10.2.0.0/16"` | N/A |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | N/A |

## GKE Add-ons
### Cloudflare Module
**Location:** `cloud/terraform/gcp/gke/modules/cloudflare/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `cloudflare_account_id` | `string` | Required | Cloudflare Account ID |
| `cloudflare_zone_id` | `string` | Required | Cloudflare Zone ID |
| `deployment_name` | `string` | Required | Deployment name for resource naming |
| `domains` | `list(string)` | Required | List of root domains to support |

### Netbird Module
**Location:** `cloud/terraform/gcp/gke/modules/netbird/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `netbird_proxy_token` | `string` | Required | The Proxy Token generated from the NetBird dashboard |
| `deployment_name` | `string` | Required | Deployment name for resource naming |
| `namespace` | `string` | `"infra"` | Namespace to deploy the NetBird agent |

## Security & Policy (Kyverno)
**Location:** `cloud/terraform/gcp/kyverno/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `deployment_name` | `string` | Required | Deployment name, used for GKE cluster identification |
| `kyverno_namespace` | `string` | `"kyverno"` | N/A |
| `project_id` | `string` | Required | The Google Cloud Project ID |
| `region` | `string` | `"us-central1"` | The GCP region |
| `spot` | `bool` | `true` | Enable spot node policy |

## GitOps Platform
**Location:** `cloud/terraform/gcp/gitops/platform/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argo_cd_auth_config` | `object` | See `variables.tf` | Configuration object for ArgoCD authentication and RBAC |
| `argo_cd_domain` | `string` | `""` | N/A |
| `argo_cd_github_webhook_config` | `object` | See `variables.tf` | Configuration object for ArgoCD authentication and RBAC |
| `argo_cd_namespace` | `string` | `"argo-cd"` | N/A |
| `crossplane_namespace` | `string` | `"crossplane-system"` | N/A |
| `deployment_name` | `string` | `"liferay-gcp"` | N/A |
| `enable_argo_cd_ui_tools` | `bool` | `true` | N/A |
| `external_secrets_namespace` | `string` | `"external-secrets"` | N/A |
| `project_id` | `string` | Required | N/A |
| `region` | `string` | `"us-central1"` | N/A |

### Argo CD Auth Resources Module
**Location:** `cloud/terraform/gcp/gitops/platform/modules/argo_cd_auth_resources/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argo_cd_auth_config` | `object` | Required | Configuration object for ArgoCD authentication and RBAC |

## GitOps Resources
**Location:** `cloud/terraform/gcp/gitops/resources/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argo_cd_namespace` | `string` | `"argo-cd"` | N/A |
| `crossplane_namespace` | `string` | `"crossplane-system"` | N/A |
| `deployment_name` | `string` | `"liferay-gcp"` | N/A |
| `external_secrets_namespace` | `string` | `"external-secrets"` | N/A |
| `infrastructure_git_repo_config` | `object` | See `variables.tf` | N/A |
| `liferay_gcp_helm_chart_config` | `object` | See `variables.tf` | N/A |
| `infrastructure_helm_chart_config` | `object` | See `variables.tf` | N/A |
| `infrastructure_provider_helm_chart_config` | `object` | See `variables.tf` | N/A |
| `liferay_git_repo_config` | `object` | See `variables.tf` | N/A |
| `liferay_git_repo_url` | `string` | Required | N/A |
| `liferay_workspace_git_repo_path` | `string` | `""` | The GitHub repository path in 'owner/repo' format (e.g. Ziggy-AZ/cne-workspace). |
| `liferay_git_repo_auth_method` | `string` | `"https"` | N/A |
| `liferay_helm_chart_name` | `string` | `"liferay-gcp"` | N/A |
| `liferay_helm_chart_version` | `string` | Required | N/A |
| `region` | `string` | `"us-central1"` | N/A |
| `github_workload_identity_pool_id` | `string` | `"github-pool"` | The ID of the GitHub Workload Identity Pool |
| `project_id` | `string` | Required | N/A |
| `root_domain` | `string` | Required | N/A |
