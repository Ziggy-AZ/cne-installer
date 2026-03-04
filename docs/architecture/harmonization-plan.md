# Architecture Harmonization Report

## 1. Executive Summary
This report analyzes the differences between the current GCP implementation (located in `cloud/`) and the AWS implementation (located in `portal/cloud/`) and provides a roadmap for harmonization. Both implementations share a compatible architectural foundation (**Crossplane** and **ArgoCD**), but have diverged in directory structure, coding standards, and component versioning.

## 2. Technical Comparison

### 2.1 Core Technologies
| Component | GCP Implementation (`cloud/`) | AWS Implementation (`portal/cloud/`) |
| :--- | :--- | :--- |
| **Infra Manager** | OpenTofu / Terraform | OpenTofu / Terraform |
| **Cloud Provider** | Crossplane (GCP) | Crossplane (AWS) |
| **GitOps** | ArgoCD | ArgoCD |
| **Policy Engine** | Kyverno (Mutating Policies) | None |
| **Custom Logic** | YAML based | Custom Go Operator (`operator/`) |

### 2.2 Directory Structure
*   **GCP (`cloud/`):** Root-level directory. Flat and focused. Modularized into functional stacks (`gar`, `gke`, `gitops`, `kyverno`).
*   **AWS (`portal/cloud/`):** Nested directory. Designed for multi-cloud from the start (contains placeholders for Alibaba, Azure, and GCP).

### 2.3 Code Formatting & Style (Visible Divergence)
*   **Indentation:** GCP uses **Spaces** (Standard); AWS uses **Tabs**.
*   **Assignment:** GCP uses **Spaces around `=`** (`key = value`); AWS uses **no spaces** (`key=value`).
*   **Naming:** Both use hyphenated filenames, but AWS tends to prefix Kubernetes resources with `${local.cluster_name}-` more strictly.

### 2.4 Component Versions
*   **Liferay Default Chart:** GCP is on `0.1.4`, AWS is on `0.3.0`.
*   **ArgoCD Chart:** GCP is on `9.4.4`, AWS is on `9.1.5`.

---

## 3. Harmonization Roadmap

### Phase 1: Directory Unification
Adopt the `portal/cloud/` structure as the standard for multi-cloud compatibility.
1.  **Move GCP Stack:** Migrate `cloud/terraform/gcp/*` to `portal/cloud/terraform/gcp/`.
2.  **Consolidate Helm:** Move `cloud/helm/*` to `portal/cloud/helm/gcp/` and reconcile the `default` chart.
3.  **Consolidate Scripts:** Move root-level `.sh` scripts into `portal/cloud/scripts/`.

### Phase 2: Style Standardization (Linting)
Standardize on the OpenTofu/Terraform idiomatic style (Spaces, not Tabs).
1.  Apply `tofu fmt -recursive` across the entire `portal/cloud` tree.
2.  Ensure CI/CD enforces this style globally.

### Phase 3: Resource Convention Alignment
1.  **Shared Locals:** Create a shared `locals` pattern for both clouds so that naming conventions (like bucket suffixes and service account prefixes) are identical.
2.  **Logic Consolidation:** Evaluate if the Go `operator` (AWS) and `Kyverno` (GCP) should be merged or if one should replace the other for cross-cloud consistency.

### Phase 4: Version Synchronization
1.  Align the `liferay-default` Helm chart to a single version (e.g., `0.3.x`).
2.  Synchronize ArgoCD and Crossplane provider versions.

---

## 4. Immediate Next Steps
1.  **Reformat AWS Code:** Run recursive formatting on `portal/cloud/` to align with the project standard.
2.  **Migrate GCP Files:** Begin the move of `cloud/` files into the `portal/cloud/` hierarchy.
3.  **Merge Default Charts:** Reconcile the differences between the two versions of the `liferay-default` Helm chart.
