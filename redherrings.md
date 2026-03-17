# Security Scan Red Herrings

This document details security scan warnings from Trivy and Checkov that have been identified as non-applicable or "false positives" for this specific architecture. These checks have been suppressed in our configuration.

---

## 1. Firewall Rule: Large Port Range / All Ports
**Scanners:** Trivy (GCP-0072, GCP-0074), Checkov (CKV_GCP_2)

### Issue
The scanners flag the `allow_internal` firewall rule because it allows broad access to protocols and ports.

### Analysis
The `allow_internal` rule is specifically scoped to **Internal CIDR ranges only** (`pod_cidr`, `service_cidr`, `vpc_cidr`). It is designed to allow service-to-service communication within the trusted VPC and Kubernetes network.

*   **ICMP Confusion:** Scanners often flag ICMP rules as "Allowing All Ports" because ICMP doesn't have the concept of ports. 
*   **Broad Access:** Modern service meshes and discovery tools require flexible internal port access.

### Rationale for Suppression
Since this rule is **not exposed to the internet** and only affects internal, trusted traffic, the risk is negligible compared to the operational requirement for cluster internal communication.

---

## 2. GKE Network Policy (CKV_GCP_12)
**Scanners:** Checkov (CKV_GCP_12), Trivy

### Issue
Ensure Network Policy is enabled on Kubernetes Engine Clusters.

### Analysis
We use **GKE Dataplane V2** (`ADVANCED_DATAPATH`). In this modern architecture, Network Policy is powered by Cilium and is **enabled by default**.

*   **API Conflict:** If you try to explicitly set the legacy `network_policy { enabled = true }` block while using Dataplane V2, the GCP API will reject the request with an error: *"Enabling NetworkPolicy for clusters with DatapathProvider=ADVANCED_DATAPATH is not allowed."*

### Rationale for Suppression
The scanners are looking for a legacy boolean flag that is incompatible with the modern, secure-by-default dataplane we have chosen. The cluster is protected, but the scanner cannot "see" it via the old metadata checks.

---

## 3. GKE Metadata Server (CKV_GCP_69)
**Scanners:** Checkov (CKV_GCP_69)

### Issue
Ensure the GKE Metadata Server is Enabled.

### Analysis
GKE Metadata Server is required for **Workload Identity**. 

*   **Deployment Pattern:** We follow the GCP best practice of setting `remove_default_node_pool = true`. 
*   **The False Positive:** The scanner checks the `google_container_cluster` (the primary resource) for metadata server settings. However, since the default pool is deleted immediately after cluster creation, we do not define those settings there to avoid Terraform state churn and "Forces Replacement" loops.
*   **Actual State:** The GKE Metadata Server **is enabled** on the actual worker nodes via the `google_container_node_pool` resource.

### Rationale for Suppression
The check fails on the cluster resource due to our lifecycle management strategy (deleting the default pool), but the security requirement is fully satisfied on all active nodes where the workloads actually run.
