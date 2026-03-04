# Infrastructure Provisioning (Crossplane) Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) and Amazon Web Services (AWS) Crossplane provider implementations for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation | AWS Implementation |
| :--- | :--- | :--- |
| **Provider Package Version** | `v2.5.0` (latest) | `v2.3.0` |
| **Provider Families** | Uses `upbound-provider-family-gcp`. | Uses `provider-family-aws`. |
| **Granular Providers** | Explicitly defines `provider-gcp-sql`, `provider-gcp-storage`, `provider-gcp-compute`, `provider-gcp-cloudplatform`. | Explicitly defines `provider-aws-backup`, `provider-aws-ec2`, `provider-aws-iam`, `provider-aws-opensearch`, `provider-aws-rds`, `provider-aws-s3`. |
| **Sync Waves** | Consistent sync-wave strategy (`-80` for most). | Consistent sync-wave strategy (`-80` for most, `-85` for family). |
| **IAM Integration** | Relies on GKE Workload Identity (GCP side). | Explicitly managed IAM roles and IRSA for each provider. |
| **CRD Management** | Handled via the Crossplane Provider lifecycle. | Also manages the ECK Operator and Gateway CRDs within the Helm chart. |

## 2. Key Differences & Observations

### 2.1 Provider Versioning
The **GCP Implementation** uses more recent provider versions (`v2.5.0`) compared to the **AWS Implementation** (`v2.3.0`). This ensures access to newer resources and bug fixes, especially in the evolving SQL and storage providers.

### 2.2 Provider Granularity
Both implementations follow the "provider-per-service" model (e.g., separate providers for SQL, S3/Storage, and IAM). This minimizes the overhead of CRDs and improves the performance of the Crossplane control plane. GCP includes a `compute` provider, which is not as prominently featured in the AWS setup (which relies more on `ec2`).

### 2.3 IAM and Service Account Handling
The **AWS Implementation** is more explicit about IAM roles and OIDC integration for the providers themselves, which is a requirement for AWS IRSA. The **GCP Implementation** typically uses a more unified Workload Identity approach for the GKE nodes where Crossplane runs.

## 3. Recommendations for GCP Harmonization
1.  **Version Standard:** Ensure the AWS team is aware of the `v2.5.0` update for Upbound providers and consider aligning if stability allows.
2.  **Naming Convention:** Adopt the AWS standard for `ProviderConfig` naming (e.g., `default`) where appropriate, to allow for more portable resource compositions.
3.  **Sync Wave Consistency:** Ensure all Crossplane-related resources (Providers, RuntimeConfigs, ProviderConfigs) are correctly tiered using the `-80` sync-wave standard to avoid race conditions during deployment.
