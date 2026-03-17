# GKE Connect Gateway

## Security Summary: Private by Default
By default, our GKE clusters are provisioned as **Private Clusters**. This means the Kubernetes API server (the control plane) does not have a public IP address and is completely unreachable from the public internet. This "Private by Default" stance significantly reduces the cluster's attack surface.

The Connect Gateway is the authorized and secure mechanism used to interact with these private API servers from outside the VPC without compromising this network isolation.

## 1. Architecture Overview

Your clusters are registered as members of a **Fleet** (formerly GKE Hub). The Connect Gateway provides a unified API surface and a secure tunnel to the cluster control plane.

## 2. Prerequisites

The following APIs must be enabled (handled by `setup-spacelift.sh` or `apis.tf`):
- `connectgateway.googleapis.com`
- `gkehub.googleapis.com`

## 3. Configuring Access

To use the gateway, an identity needs both GCP IAM permissions and Kubernetes RBAC permissions.

### IAM Permissions
Assign the following roles to the user or service account in GCP:
- `roles/gkehub.gatewayAdmin` (or `gatewayReader` / `gatewayEditor`).
- `roles/gkehub.viewer`.

### Kubernetes RBAC
GKE provides **implicit mapping** for high-level IAM roles. If you have `roles/container.admin` or are a Project Owner, you are automatically a `cluster-admin` and do not need a manual binding.

However, for **least-privilege access**, you should use explicit bindings:
1.  Grant the user `roles/gkehub.gatewayReader` in GCP IAM (this allows them to "see" the gateway but not the project).
2.  Create a `ClusterRoleBinding` inside the cluster to define their specific K8s permissions.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gateway-user-admin
subjects:
- kind: User
  name: user@example.com # The GCP user email
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

## 4. Usage

To get credentials for a private cluster via the gateway:

1.  **List memberships:**
    ```bash
    gcloud container fleet memberships list
    ```

2.  **Get credentials:**
    ```bash
    gcloud container fleet memberships get-credentials [MEMBERSHIP_NAME]
    ```

3.  **Verify access:**
    ```bash
    kubectl get nodes
    ```

## 5. Pricing and Data Transfer (2026)

### Management Fee
As of early 2026, **Connect Gateway is included at no additional cost** as part of the standard GKE management fee ($0.10/hour per cluster). It does not require a GKE Enterprise license for base functionality.

### Data Transfer (Egress)
While there is no fee for the gateway itself, all data passing through the gateway is subject to standard Google Cloud **Egress** rates.

**⚠️ 2026 Cost Update:** Google Cloud has announced a significant increase in egress pricing effective **May 1, 2026**. Data transfer rates in North America and Europe are expected to double (from $0.04/GB to **$0.08/GB**). You should monitor `kubectl` usage that involves large data transfers (e.g., `cp` or large `logs` streams) to manage costs effectively.

## 6. References

For detailed information on advanced configurations and troubleshooting, refer to the official Google Cloud documentation:
- [Connect Gateway Overview](https://cloud.google.com/anthos/fleet-management/docs/concepts/connect-gateway)
- [Configuring Gateway Access](https://cloud.google.com/anthos/fleet-management/docs/how-to/setup-connect-gateway)
- [Authenticating with the Gateway](https://cloud.google.com/anthos/fleet-management/docs/how-to/use-connect-gateway)
