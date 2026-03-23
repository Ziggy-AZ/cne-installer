# GCP GitOps Platform Strategy

## Overview
This document outlines the strategy for implementing the `gitops/platform` directory for GCP, aiming for parity with the existing AWS implementation in `liferay-portal`.

## Comparison of Implementations

| Feature | AWS (Target Parity) | GCP (cne-installer) | GCP (cne-gcp) |
| :--- | :--- | :--- | :--- |
| **ArgoCD Version** | 9.1.5 | 9.4.4 | 9.4.4 |
| **Crossplane Version** | 2.1.3 | 2.1.4 | 2.1.4 |
| **External Secrets** | Standard Helm | Standard Helm | Standard Helm |
| **Health Checks** | AWS Liferay Infra Lua | GCP Liferay Infra Lua | GCP Liferay Infra Lua |
| **Auth/SSO** | Basic | Advanced Modules | Advanced Modules |
| **Networking** | ClusterIP (Internal) | Gateway API HTTPRoute | Gateway API HTTPRoute |
| **Resource Limits** | AWS Optimized | GCP Optimized | GCP Optimized |

### Key Observations
1.  **AWS Implementation**: Focuses on core platform components (ArgoCD, Crossplane, External Secrets, Argo Workflows) with minimal external dependencies.
2.  **cne-installer**: Closely mirrors the AWS structure but introduces GKE-specific features like Gateway API and advanced authentication modules.
3.  **cne-gcp**: Similar to `cne-installer` but used in a more "environment-centric" way with remote state data sources.

## Implementation Strategy

To achieve parity with AWS while maintaining GCP best practices, we will follow these steps:

### 1. Structure & Layout
Maintain the standard `liferay-portal` directory structure:
```
cloud/terraform/gcp/gitops/platform/
├── argocd.tf
├── crossplane.tf
├── external-secrets.tf
├── locals.tf
├── providers.tf
├── variables.tf
└── liferayinfrastructure-health-check.lua
```

### 2. ArgoCD Implementation
- **Base Config**: Use the `values` structure from AWS but update image versions to current stable (e.g., 9.4.4).
- **GCP Customization**: Keep the `application.allowedNodeLabels` configuration from the existing GCP attempts to handle GKE-specific node labels (Spot, Compute Class).
- **Health Check**: Port the `liferayinfrastructure-health-check.lua` from `cne-installer` as it is already optimized for GCP.
- **Networking**: While AWS uses simple ClusterIP, GCP requires Gateway API integration for production-ready ingress. We will include the `HTTPRoute` logic but keep it optional based on a `argocd_domain` variable.

### 3. Crossplane Implementation
- **Parity**: Use the same provider/version strategy as AWS.
- **Node Affinity**: Include the GKE-specific `nodeSelector` and `tolerations` logic from `cne-gcp` to ensure components land on the correct node pools (e.g., general-purpose vs. spot).

### 4. External Secrets
- **Parity**: One-to-one port of the AWS implementation, ensuring the GCP Workload Identity bindings are used instead of AWS IAM roles.

### 5. Strategy for "Extra" Features
The advanced authentication modules (`argocd-auth-resources`, `argocd-ui-tools`) found in `cne-installer` will be **moved to optional modules** or handled in a separate layer. For core parity, we will focus on the standard `helm_release` with customizable `values`.

## Next Steps
1.  Initialize the `cloud/terraform/gcp/gitops/platform` directory in `liferay-portal`.
2.  Port core `.tf` files from `cne-installer` but strip out non-essential "experimental" features.
3.  Verify provider compatibility with the GKE cluster created by the `gke/` folder.
4.  Standardize variables to match the AWS naming conventions where applicable.
