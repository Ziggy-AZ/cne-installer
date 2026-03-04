# Artifact Management Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) Artifact Registry (GAR) implementation and the Amazon Web Services (AWS) Elastic Container Registry (ECR) implementation for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation (GAR) | AWS Implementation (ECR) |
| :--- | :--- | :--- |
| **Resource Type** | `google_artifact_registry_repository` | `aws_ecr_repository` |
| **Encryption** | **KMS-Managed:** Integrated with Cloud KMS for repository encryption at rest. | **Managed/KMS:** Supports both default AWS managed and KMS keys. |
| **Tag Mutability** | **Immutable:** `immutable_tags = true` | **Immutable:** `image_tag_mutability = "IMMUTABLE"` |
| **Lifecycle Policies** | **Advanced Cleanup:** Native support for `KEEP` and `DELETE` policies based on version count and age. | **Lifecycle Policies:** Supported via separate `aws_ecr_lifecycle_policy` (not shown in basic `main.tf`). |
| **Public Access** | **IAM-Based:** Optional `roles/artifactregistry.reader` for `allUsers`. | **Public ECR:** Requires separate Public ECR repository (standard ECR is private by default). |
| **Scanning** | **Automatic:** Managed via vulnerability scanning API. | **Scan on Push:** Explicitly enabled via `scan_on_push = true`. |

## 2. Key Differences & Observations

### 2.1 Configuration Depth
The **GCP Implementation** in `cloud/terraform/gcp/gar` is highly descriptive. It includes explicit KMS key creation, IAM member assignment for the service agent, and detailed cleanup policies. This ensures a "secure by default" posture with automated house-keeping.

The **AWS Implementation** in `portal/cloud/terraform/aws/ecr` is more minimal, relying on a `for_each` loop to create multiple repositories. While efficient for bulk creation, it lacks the explicit lifecycle management and fine-grained encryption configuration seen in the GCP counterpart.

### 2.2 Repository Granularity
GCP uses a single repository defined by `deployment_name`, whereas the AWS implementation is designed to handle multiple repository names passed via `var.ecr_repository_names`.

### 2.3 Cleanup and Costs
GCP's use of `cleanup_policies` (keeping 10 versions and deleting anything older than 30 days) is a proactive approach to cost management. The AWS implementation lacks these policies in its current state, which could lead to uncapped storage costs over time.

## 3. Recommendations for GCP Harmonization
1.  **Repository Granularity:** Align GCP with the AWS standard by allowing multiple repositories if the deployment requires separate images (e.g., for different services or helper tools).
2.  **Tagging Standard:** Ensure the `DeploymentName` label is applied to the GAR repository to match AWS resource tagging standards.
3.  **Naming Convention:** Use ASCII sort order for variables and resource definitions where possible to maintain consistency with the AWS team's preferred style.
