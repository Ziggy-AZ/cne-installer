# GitHub Issues Progress Report

This document tracks the status of issues from the `allen-ziegenfus/cne-gcp` repository relative to the current state of the GCP implementation.

## Executive Summary
A significant portion of the core infrastructure and platform stability issues have been addressed through recent refactoring, specifically around **ArgoCD Brand Integrity**, **Gateway API migration**, and **Documentation**. However, complex "Day 2" operations like **Database state checking**, **Cost estimation**, and **Harmonized Backups** remain open.

---

## 1. Completed Issues ✅

The following issues have been fully addressed in the current codebase:

| Issue # | Title | Resolution |
| :--- | :--- | :--- |
| **87** | GitHub App Flow | Implemented the GitHub App Manifest Tool in `docs/` and the Setup Guide. |
| **10** | Move to Gateway instead of ingress | Fully migrated to the Kubernetes Gateway API (Envoy Gateway) in `cloud/terraform/gcp/gke`. |
| **11** | Get gitops working in GCP | ArgoCD platform bootstrap is fully functional and validated in `cloud/terraform/gcp/gitops/platform`. |
| **24** | Auto Pilot | Cluster implementation is standardized on GKE Autopilot in `gke.tf`. |
| **22** | Allow specifying GKE CIDR ranges | CIDR ranges for Pods and Services are now dynamically calculated from `vpc_cidr` in `locals.tf`. |
| **38** | Auth woes | Resolved via the `argocd_auth_resources` module with explicit secret mapping. |
| **12** | Do we need this cluster command? | **CLOSED.** |

---

## 2. In Progress / Partially Addressed 🏗️

These issues have seen progress but require further refinement or validation:

| Issue # | Title | Status |
| :--- | :--- | :--- |
| **18** | What other folders under AWS need GCP equivalents? | Partially addressed via current architectural comparison docs. Backups and dependencies still need GCP-specific code. |
| **83** | Rework service accounts | Standardized on `argocd_` prefix, but per-environment SA granularity (Issue #50) is still pending. |
| **77** | Overlay enabled logic not working | Fixed indentation and logic in `values.yaml` recently, but needs end-to-end verification. |
| **20** | Validate deployment name length | Basic validation exists in `variables.tf`, but needs to be more robust across all modules. |
| **43** | Custom Lua scripts | Health checks are implemented for `LiferayInfrastructure`, but custom icons/buttons are pending. |

---

## 3. Remaining Tasks (TODO) 🚀

Major functional gaps that still need to be addressed:

### A. Data & Database Lifecycle
- [ ] **#85**: Include database state checker (release_ table).
- [ ] **#81**: Database startup timing/readiness issues.
- [ ] **#75**: Database/User cleanup after SQL instance deletion.
- [ ] **#49**: Cloud SQL Mutual TLS support.

### B. Platform Operations
- [ ] **#86**: Include cost estimator.
- [ ] **#88**: Logs JSON formatting pass.
- [ ] **#71**: Elasticsearch License management.
- [ ] **#18**: Port AWS Backup/Restore workflows to GCP.

### C. Security & Governance
- [ ] **#72**: CKV_GCP_49 (Service Account Impersonation check).
- [ ] **#51**: Implement full Liferay Infosec security requirements.
    - [ ] *Pending*: Apply `NetworkPolicy` manifests to restrict cross-namespace and egress traffic (required by InfoSec, even with GKE Datapath V2 enabled).
- [ ] **#34**: Address `cloudflared` pod security concerns.

---

## 4. Next Steps Recommendation
To maintain momentum, the next phase of development should focus on **Category A (Data Lifecycle)** to ensure environment teardowns and restarts are as reliable as the initial provisioning.
