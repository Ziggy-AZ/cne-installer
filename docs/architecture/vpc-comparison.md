# VPC Infrastructure Comparison

## Executive Summary
This report analyzes the architectural differences between the Google Cloud Platform (GCP) VPC implementation and the Amazon Web Services (AWS) VPC implementation for Liferay Cloud Native deployments.

## 1. Technical Comparison

| Feature | GCP Implementation (GKE) | AWS Implementation (EKS) |
| :--- | :--- | :--- |
| **Subnet Strategy** | **Single Subnet + Secondary Ranges:** Uses one subnet per region with alias IP ranges for Pods and Services. | **Multi-Subnet (AZ-Mapped):** Uses public and private subnet pairs across 3 Availability Zones. |
| **NAT Gateway** | **Cloud NAT:** Managed via Cloud Router and a single NAT resource. | **AWS NAT Gateway:** Uses a single NAT Gateway shared across private subnets (cost-optimized). |
| **Private Access** | **Private Service Access (PSA):** Explicitly reserves a `/16` range for VPC Peering with Google services (SQL, etc.). | **Implicit:** Uses IAM roles and security groups for service access. |
| **Ingress Integration** | **Internal Ingress:** Relies on GKE-specific secondary ranges for native routing. | **ELB/ALB Integration:** Uses specific subnet tags (`kubernetes.io/role/elb`) for Load Balancer discovery. |
| **Default CIDR** | `10.0.0.0/16` (Primary VPC), dynamically split for Pods and Services. | `10.0.0.0/16` (VPC), split into `/24` subnets. |

## 2. Key Differences & Observations

### 2.1 Networking Model
The **GCP Implementation** follows the GKE "Alias IP" model. This model is more flat; Pods and Services get their own IP ranges within the VPC but are logically part of the same subnet. This simplifies routing but requires careful management of secondary ranges to avoid exhaustion.

The **AWS Implementation** follows a traditional tiered model. Public subnets host the NAT Gateways and Load Balancers, while private subnets host the EKS worker nodes. This provides a clear boundary for internet ingress and egress.

### 2.2 Managed Service Connectivity
GCP requires an explicit **Private Service Access (PSA)** configuration (VPC Peering) to connect to services like Cloud SQL via private IP. This is handled in `vpc.tf` via `google_compute_global_address` and `google_service_networking_connection`. 

AWS typically handles this via **Interface Endpoints (PrivateLink)** or simply by placing RDS instances within the same VPC subnets, relying on Security Groups for isolation.

### 2.3 Load Balancer Discovery
AWS EKS relies on **Subnet Tagging** for both the AWS Load Balancer Controller and the legacy in-tree provider. The `portal/` implementation explicitly tags subnets with `kubernetes.io/role/elb` and `internal-elb`. 

GCP GKE Autopilot (and standard) uses **Network Endpoint Groups (NEG)** or standard Ingress objects, which do not typically require manual subnet tagging for basic operation.

## 3. Recommendations for GCP Harmonization
1.  **Flow Log Consistency:** AWS implementation doesn't explicitly define flow logs in the VPC module block shown, while GCP has them enabled. Consider standardizing the retention and sampling rates for security audits.
2.  **Tagging Standard:** Adopt the `DeploymentName` tag standard from the AWS team for all VPC resources to ensure cross-platform consistency in resource management.
3.  **Secondary Range Automation:** The GCP implementation now automatically calculates Pod and Service secondary ranges from the primary `vpc_cidr`. Ensure developers understand that this `/16` (or provided block) is mathematically partitioned to prevent overlaps.
