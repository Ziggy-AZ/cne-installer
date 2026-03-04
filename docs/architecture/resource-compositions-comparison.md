# Resource Compositions Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) and Amazon Web Services (AWS) Crossplane resource compositions for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation | AWS Implementation |
| :--- | :--- | :--- |
| **Composition Structure** | **Modular:** Split into multiple files (SQL, Storage, Search, IAM) and included via Helm. | **Monolithic:** One giant `compositions.yaml` containing all logic for all resources. |
| **Templating Engine** | `function-go-templating` (with modular `.gotmpl` and `.yaml` files). | `function-go-templating` (with a large inline template). |
| **State Management** | Uses `function-environment-configs` for persistent state across steps. | Relies on standard Crossplane observed state and pipeline steps. |
| **SQL Abstraction** | Cloud SQL (PostgreSQL) | RDS (PostgreSQL) |
| **Storage Abstraction** | Cloud Storage (GCS) | S3 Buckets |
| **Search Abstraction** | ElasticSearch (Self-managed on GKE via ECK). | OpenSearch (AWS Managed Service). |
| **Tagging** | Standard labels and annotations. | `function-tag-manager` for consistent multi-resource tagging. |

## 2. Key Differences & Observations

### 2.1 File Organization
The **GCP Implementation** in `cloud/helm/gcp-infrastructure-provider/compositions/` is highly modular. It uses separate files for different functional areas (SQL, IAM, etc.), making it easier to maintain and audit.

The **AWS Implementation** uses a single `compositions.yaml` with extensive inline logic. While this keeps the entire composition in one place, it can lead to complexity and is harder to refactor.

### 2.2 Search Strategy
GCP uses **Elastic Cloud on Kubernetes (ECK)** managed via a composition, while AWS uses the managed **OpenSearch** service. This reflects the platform-specific strengths (GKE's efficiency for operator-led workloads vs. AWS's robust managed services).

### 2.3 Tagging and Metadata
The **AWS Implementation** leverages the `function-tag-manager` for systematic tagging of all composed resources (e.g., adding `DeploymentName`). The GCP implementation relies more on standard labels, which may lead to inconsistencies if not carefully managed.

## 3. Recommendations for GCP Harmonization
1.  **Tag Manager:** Adopt the `function-tag-manager` in the GCP composition to ensure consistent tagging across all platform resources, matching the AWS team's standards for resource traceability.
2.  **Naming Convention:** Adopt the `baseName` calculation logic from the AWS implementation (incorporating account ID, deployment name, and a hash) to ensure globally unique and predictable resource names.
3.  **Variable Standard:** Standardize variable names (e.g., `environmentId`, `projectId`) to be consistent between both cloud platforms to improve cross-platform documentation and understanding.
