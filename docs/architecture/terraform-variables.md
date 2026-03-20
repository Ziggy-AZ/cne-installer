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
| `deployment_name` | `string` | `"liferay-gcp"` | Unique name for the deployment, used for resource prefixing. |
| `region` | `string` | Required | The GCP region where resources will be created. |
| `project_id` | `string` | Required | The GCP Project ID |
| `kms_key_name` | `string` | `null` | The Cloud KMS key name to encrypt the repository. |
| `create_kms_key` | `bool` | `false` | Whether to create a new Cloud KMS key for the repository. |
| `enable_public_gar_access` | `bool` | `false` | Whether to make the Artifact Registry repository public (allUsers). |

## GKE Cluster (Core)
**Location:** `cloud/terraform/gcp/gke/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `deployment_name` | `string` | Required | Unique identifier for the GKE cluster and associated resources. Must contain only lowercase letters, numbers, and hyphens. |
| `gke_security_group` | `string` | `null` | The Google Group email address for GKE RBAC (Groups-based access control). |
| `machine_type` | `string` | `"e2-standard-4"` | The GCP machine type to use for the GKE node pool. |
| `master_authorized_networks` | `list(string)` | `["10.0.0.0/16"]` | List of CIDR blocks allowed to access the GKE master endpoint. |
| `max_node_count` | `number` | `3` | Maximum number of nodes in the general-purpose node pool. |
| `min_node_count` | `number` | `1` | Minimum number of nodes in the general-purpose node pool. |
| `project_id` | `string` | Required | The GCP Project ID. |
| `region` | `string` | Required | The GCP region where the cluster will be deployed. |
| `regional_cluster` | `bool` | `true` | Whether to create a regional GKE cluster (high availability) or a zonal one. |
| `spot_instances` | `bool` | `false` | Whether to use GKE Spot Instances for the node pool to reduce cost. |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | The primary CIDR block for the VPC. Subnet, Pod, and Service ranges are automatically calculated from this block. |

## GKE Add-ons
### Cloudflare Module
**Location:** `cloud/terraform/gcp/gke/modules/cloudflare/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `cloudflare_account_id` | `string` | Required | Cloudflare Account ID |
| `cloudflare_zone_id` | `string` | Required | Cloudflare Zone ID |
| `deployment_name` | `string" | Required | Deployment name for resource naming |
| `domains` | `list(string)` | Required | List of root domains to support |

### Netbird Module
**Location:** `cloud/terraform/gcp/gke/modules/netbird/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `netbird_proxy_token` | `string" | Required | The Proxy Token generated from the NetBird dashboard |
| `deployment_name` | `string" | Required | Deployment name for resource naming |
| `namespace` | `string" | `"infra"` | Namespace to deploy the NetBird agent |

## Security & Policy (Kyverno)
**Location:** `cloud/terraform/gcp/kyverno/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `deployment_name` | `string" | Required | Deployment name, used for GKE cluster identification |
| `kyverno_namespace` | `string" | `"kyverno"` | N/A |
| `project_id" | `string" | Required | The Google Cloud Project ID |
| `region` | `string" | Required | The GCP region |
| `spot` | `bool` | `true` | Enable spot node policy |

## GitOps Platform
**Location:** `cloud/terraform/gcp/gitops/platform/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argocd_auth_config` | `object` | See `variables.tf` | Configuration object for ArgoCD authentication and RBAC |
| `argocd_domain` | `string" | `""` | N/A |
| `argocd_github_webhook_config` | `object` | See `variables.tf` | Configuration object for ArgoCD authentication and RBAC |
| `argocd_namespace` | `string" | `"argocd"` | N/A |
| `crossplane_namespace` | `string" | `"crossplane-system"` | N/A |
| `deployment_name` | `string" | `"liferay-gcp"` | N/A |
| `enable_argocd_ui_tools` | `bool` | `true` | N/A |
| `external_secrets_namespace` | `string" | `"external-secrets"` | N/A |
| `project_id" | `string" | Required | N/A |
| `region` | `string" | Required | N/A |

### Argo CD Auth Resources Module
**Location:** `cloud/terraform/gcp/gitops/platform/modules/argocd_auth_resources/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argocd_auth_config` | `object` | Required | Configuration object for ArgoCD authentication and RBAC |

## GitOps Resources
**Location:** `cloud/terraform/gcp/gitops/resources/`

| Variable Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `argocd_namespace` | `string" | `"argocd"` | N/A |
| `crossplane_namespace` | `string" | `"crossplane-system"` | N/A |
| `deployment_name` | `string" | `"liferay-gcp"` | N/A |
| `external_secrets_namespace` | `string" | `"external-secrets"` | N/A |
| `infrastructure_git_repo_config` | `object` | See `variables.tf` | N/A |
| `liferay_gcp_helm_chart_config` | `object` | See `variables.tf` | N/A |
| `infrastructure_helm_chart_config` | `object` | See `variables.tf` | N/A |
| `infrastructure_provider_helm_chart_config" | `object` | See `variables.tf` | N/A |
| `liferay_git_repo_config` | `object` | See `variables.tf` | N/A |
| `liferay_git_repo_url` | `string" | Required | N/A |
| `liferay_workspace_git_repo_path` | `string" | `""` | The GitHub repository path in 'owner/repo' format (e.g. Ziggy-AZ/cne-workspace). |
| `liferay_git_repo_auth_method` | `string" | `"https"` | N/A |
| `liferay_helm_chart_name` | `string" | `"liferay-gcp"` | N/A |
| `liferay_helm_chart_version` | `string" | Required | N/A |
| `region` | `string" | Required | N/A |
| `github_workload_identity_pool_id` | `string" | `"github-pool"` | The ID of the GitHub Workload Identity Pool |
| `project_id" | `string" | Required | N/A |
| `root_domain` | `string" | Required | N/A |
