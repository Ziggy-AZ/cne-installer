# Kubernetes Orchestration Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) GKE Autopilot implementation and the Amazon Web Services (AWS) EKS implementation for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation (GKE Autopilot) | AWS Implementation (EKS) |
| :--- | :--- | :--- |
| **Cluster Mode** | **Autopilot:** Fully managed node management and configuration. | **Managed Node Groups / Auto Mode:** `compute_config.enabled = true` indicates a managed node pool setup. |
| **Node Management** | **Managed by Google:** No direct control over nodes; GKE automatically provisions and scales nodes. | **Managed by AWS:** Managed node pools are used, with specific instance types (not explicitly shown in the module, but implied by `node_pools`). |
| **Add-ons** | **Implicit:** Most standard features are included or managed as part of the Autopilot experience. | **Explicit:** EKS Add-ons are explicitly defined (e.g., `vpc-cni`, `aws-ebs-csi-driver`, `metrics-server`, `amazon-cloudwatch-observability`). |
| **Security (IAM/OIDC)** | **Workload Identity:** Integrated with Google IAM via `identity_namespace = "enabled"`. | **IRSA (IAM Roles for Service Accounts): IRSA is explicitly enabled via `enable_irsa = true` with associated IAM roles and OIDC provider.** |
| **Networking** | **Native Alias IP:** Direct VPC integration with secondary ranges for Pods and Services. | **VPC-CNI:** Explicitly managed as an add-on, using VPC IP addresses for Pods. |
| **Storage Class** | **Standard (default):** Typically `standard-rwo`. | **gp3:** Explicitly defined as `gp3` via `kubernetes_storage_class_v1`. |

## 2. Key Differences & Observations

### 2.1 Management Model
The **GCP Implementation** uses GKE Autopilot, which significantly reduces the operational burden. Node provisioning, scaling, and maintenance are handled entirely by Google. This is ideal for simplicity and cost-efficiency (pay-per-pod).

The **AWS Implementation** uses a managed node approach. While `compute_config.enabled = true` suggests an "Auto Mode-like" experience, it still requires more explicit configuration of add-ons (EBS CSI, CloudWatch Observability, etc.) compared to the Autopilot model.

### 2.2 Observability and Add-ons
AWS takes a much more granular approach to add-ons. Features like CloudWatch observability and S3 CSI drivers are explicitly managed via Terraform resources. GCP Autopilot provides many of these features as managed services, reducing the amount of "glue" code needed in Terraform.

### 2.3 Secrets Encryption
AWS explicitly defines a KMS key and alias for EKS secrets encryption, ensuring data at rest within ETCD is encrypted. GCP Autopilot typically handles this by default with Google-managed keys, though it can also be configured with customer-managed keys (not shown).

## 3. Recommendations for GCP Harmonization
1.  **Storage Class Consistency:** Ensure GCP uses `premium-rwo` or `standard-rwo` to match the performance expectations of AWS `gp3` storage where necessary.
2.  **Add-on Parity:** While Autopilot handles much of this, ensure any necessary GKE-specific add-ons (like Config Connector or GCS Fuse) are explicitly documented or enabled if they provide equivalent functionality to the AWS add-ons.
3.  **Variable Naming:** Standardize on `deployment_name` and use ASCII sort order for all variables and resources to align with the AWS team's standards.
