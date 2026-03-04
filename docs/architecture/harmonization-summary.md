# Harmonization Strategy & Feature Matrix

## Executive Summary: Alignment Overview
The GCP and AWS implementations for Liferay Cloud Native are **architecturally aligned (~80%)** but **operationally divergent**. Both platforms share a core foundation based on **Crossplane**, **ArgoCD**, and the **Kubernetes Gateway API**. 

The primary differences stem from:
1.  **Platform Constraints**: GKE Autopilot's strict admission control requires manual CRD management for Gateway API, whereas AWS EKS is more permissive.
2.  **Configuration Philosophy**: The GCP implementation is more **modular and descriptive** (e.g., granular Crossplane compositions, detailed Artifact Registry policies), while the AWS implementation is more **monolithic and automated** (e.g., single-file compositions, direct OCI chart consumption).
3.  **Maturity Levels**: The AWS team is currently ahead in Helm chart versioning (`0.3.0` vs `0.1.6`) and standardized tagging, while the GCP team has a more feature-rich ArgoCD platform setup (SSO, UI Tools).

## 1. Feature Matrix

| Feature Area | Feature | GCP (GKE) | AWS (EKS) | Alignment |
| :--- | :--- | :---: | :---: | :---: |
| **Artifacts** | Immutable Tags | Yes | Yes | High |
| | Lifecycle Cleanup | Yes | No | Low |
| **Kubernetes** | Managed Control Plane | Yes | Yes | High |
| | Auto-scaling Nodes | Yes (Autopilot) | Yes (Managed) | Medium |
| | Explicit Secrets Encryption | No (Default) | Yes (KMS) | Medium |
| **Networking** | Gateway API (Envoy) | Yes | Yes | High |
| | ProxyProtocol (Real IP) | No | Yes | Low |
| | Multi-AZ Subnetting | No (Flat) | Yes (Tiered) | Low |
| **Crossplane** | Modular Compositions | Yes | No | Low |
| | Direct Workload Identity | Yes | Yes (IRSA) | High |
| | Tag Manager | No | Yes | Low |
| **GitOps** | ArgoCD SSO / UI Tools | Yes | No | Medium |
| | Sync-Wave Strategy | Yes (Limited) | Yes (Full) | Medium |
| **Application** | GCS Fuse Support | Yes | No | N/A |
| | Native S3 Integration | No | Yes | N/A |

## 3. Compliance & Architectural Standards

### 3.1 Brand Integrity (ArgoCD)
The project adheres to strict **Brand Integrity** rules established by project leadership. The transition from `argocd` to `argo_cd` (identifiers) and `ArgoCD` (text) is a direct implementation of these standards.

*   **Core Mandate:** GEMINI.md (Section 3: Brand Integrity)
*   **Original Authority:** Brian Chan, Commit [`5563d217`](https://github.com/liferay/liferay-portal/commit/5563d217d4cecc1f984969d90bc5454539ed6b60) - *"LCD-49975 Brand name is Argo CD"*

This ensures that the GCP implementation is not only technically functional but also architecturally compliant with the project's brand and naming conventions.

## 4. Harmonization TODO List

### Priority 1: GitOps & Reliability (Immediate)
- [ ] **Adopt Sync-Waves**: Update all GCP resources (Gateway, EnvoyProxy, Compositions) to use the AWS standard sync-wave tiering (e.g., `-110` for infra, `-30` for gateway).
- [ ] **Standardize Tags**: Implement `function-tag-manager` in GCP Crossplane compositions to ensure the `DeploymentName` label is consistently applied to all cloud resources.
- [ ] **Namespace Consistency**: Ensure ArgoCD is installed in the same namespace across both clouds (align on either `argo-cd` or `argocd`).

### Priority 2: Security & Portability (Short-term)
- [ ] **Real IP Support**: Implement `GCPGatewayPolicy` (or equivalent) in the `gateway-infra` chart to mirror the AWS `ClientTrafficPolicy` for ProxyProtocol support.
- [ ] **EKS Secrets Encryption**: Align GCP with the AWS standard by explicitly configuring Customer Managed Encryption Keys (CMEK) for GKE ETCD secrets.
- [ ] **Property Abstraction**: Update `liferay-gcp` to use the AWS-style `$[env:VAR]` pattern for all dynamic properties in `portal-ext.properties`.

### Priority 3: Refactoring & Maintenance (Long-term)
- [ ] **Version Synchronization**: Perform a manual audit of `liferay-default:0.3.0` (AWS) and port all logic improvements to the GCP version.
- [ ] **OCI Orchestration**: Evaluate moving the `gateway-infra` and `liferay-gcp` charts to direct OCI consumption in Terraform, eliminating the "local wrapper" maintenance overhead where Autopilot allows.
- [ ] **ASCII Sort Audit**: Perform a project-wide linting pass to ensure all variables and locals are sorted by ASCII value as per `GEMINI.md`.

## Conclusion
Harmonizing these two environments will provide a "Single Pane of Glass" experience for administrators and developers, regardless of the underlying cloud provider. By adopting the AWS team's naming and tagging standards while exporting GCP's platform richness (SSO/UI Tools), we can achieve a truly world-class multi-cloud infrastructure.
