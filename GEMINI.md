# Gemini Project Memories

## Brian Chan Style Guidelines (The Definitive Ruleset)

### 1. Sorting (The "ASCII First" Rule)
*   **Case-Sensitive ASCII Sort:** ALL lists (variables, imports, list items, `.gitignore` entries) MUST be sorted by ASCII values.
    *   Uppercase letters come BEFORE lowercase letters.
    *   Symbols like `*` (42) come BEFORE `.` (46).
*   **Attribute Alphabetization:** Attributes within Terraform blocks, JSON objects, or YAML maps MUST be sorted alphabetically (e.g., `description` before `name`).
*   **Local/Variable Sorting:** All `locals` and Helm template variables MUST be declared in alphabetical order.
*   **Exception:** Order can only be broken for strict functional dependencies (e.g., creating a VPC before a Subnet).

### 2. Documentation & UI Strings (The "Wordsmith" Rules)
*   **Escaped Quoting:** Use escaped double quotes (`\"`) for highlighting values in log strings. NEVER use single quotes (`'`).
*   **Minimalist Documentation:** Avoid optional \"description\" strings in Terraform configurations.
*   **No Trailing Slashes:** URIs and bucket paths in logs should not have trailing slashes (e.g., `gs://bucket`).
*   **Sentence Termination:** Every log message and status output MUST end with a single period (`.`). NEVER use exclamation marks (`!`) or ellipses (`...`).
*   **The "Tesla car" Rule:** Use lowercase for common technical nouns (`cluster`, `green`, `infrastructure`, `password`, `ready`, `red`, `unreachable`, `username`, `yellow`) unless they start a sentence.
*   **Voice Style:** Prefer "does not exist" over "not found" (Direct Voice).

### 3. Bash & Terraform Logic (The "Simplify" Rules)
*   **Brand Integrity:** Use `argocd` (identifiers) and `ArgoCD` (text).
*   **Declaration & Assignment:** In Bash, consolidate `local` declaration and assignment: `local var="${val}"`. **Exception:** Split them only if using a sub-shell:
    ```bash
    local var
    var=$(cmd)
    ```
*   **Loop Syntax:** For `until` or `while` loops, move the `do` keyword to its own line and remove the preceding semicolon.
*   **Main Function Wrapping:** Wrap all non-trivial inline shell scripts in a `function main { ... }` block and call it at the end.
*   **No Abbreviations:** Use full descriptive names: `configuration_json_file` instead of `config_file`.
*   **No Assignment Spacing:** Remove spaces around `=` in Shell and Terraform: `key=value`.
*   **Trailing Commas:** All lists (except JSON) MUST use trailing commas for every element.
*   **Vertical Density:** Remove empty lines between related resource or output blocks.
*   **Vertical Padding:** Use empty `echo ""` commands to group output logically in CLI tools.
*   **Vertical Script Spacing:** Add empty lines between major shell statements and inside loop bodies to improve readability.

### 4. Code Maintenance
*   **Commit Messages:** Prefix with a JIRA ID (e.g., `LCD-12345`). Use `Wordsmith`, `Simplify`, or `Sort` as summaries for maintenance tasks.
*   **Redundancy Pruning:** Actively remove unnecessary `.gitignore` files or logic that is already covered by parent configurations.

## Security & Compliance Guidelines (Corporate Standards)

### 1. Core Infrastructure
*   **Encryption:** Use Customer Managed Encryption Keys (CMEK) for all state storage, managed databases, and backup vaults.
*   **Kubelet Hardening:** Disable anonymous authentication (`--anonymous-auth=false`) and the read-only port (10255).
*   **Metadata Security:** Always enable the cloud provider metadata server proxy (GKE Metadata Server or IMDS v2).
*   **Module Pinning:** All Terraform module sources MUST be pinned to an immutable commit hash. Do not use floating tags or branches (P2 finding).
*   **Node OS:** Use container-optimized operating systems (GCP COS or AWS Bottlerocket).
*   **Private Clusters:** All GKE/EKS nodes must be deployed in private subnets with no public IP addresses. Use Cloud NAT for egress.

### 2. IAM & Secrets
*   **Least Privilege:** Bind permissions at the resource level (bucket, database) rather than project level. Prohibit wildcard (`*`) access in IAM policies.
*   **No Secrets in SCM:** Never store secrets (even encrypted) in source control. Use GCP Secret Manager or AWS Secrets Manager.
*   **Secret Injection:** Sync secrets to Kubernetes exclusively via the External Secrets Operator. Never define secrets in `env` blocks of Deployments or ConfigMaps.
*   **SSO Enforcement:** All administrative interfaces (ArgoCD, Spacelift) MUST use SSO via OIDC/SAML tied to corporate IdP groups (P0 finding).
*   **Workload Identity:** Use short-lived credentials via Workload Identity (GCP) or IRSA (AWS). Never share service accounts across multiple workloads.

### 3. Network Isolation
*   **Administration Access:** Restrict control plane access to trusted networks (GKE Authorized Networks). Totally disable public access if possible.
*   **Egress Control:** Enforce default-deny egress policies for workloads. Allow egress only to explicitly approved destinations based on application requirements.
*   **Firewall Explicitization:** All network firewall rules (Security Groups) must be explicitly defined, firmly attached to resources, and include an auditing description (P0 finding).
*   **Internal Communication:** Traffic to cloud managed services (Cloud SQL, GCS) must stay within private networks (VPC Peering, PSC, Private Google Access).
*   **Namespace Isolation:** Enforce default-deny ingress policies. Deny cross-namespace traffic by default using Kubernetes NetworkPolicies.

### 4. Pod Runtime Security
*   **Capability Dropping:** Containers must drop all Linux capabilities (`drop: ["ALL"]`).
*   **Non-Root Execution:** All containers must run as a non-root user (`runAsNonRoot: true`, `runAsUser: 1000`).
*   **Privilege Escalation:** Prohibit privileged containers and privilege escalation.
*   **Pod Security Standards:** Enforce the Kubernetes Pod Security 'Restricted' profile across all application namespaces.
*   **Root Filesystem:** Use a read-only root filesystem for all containers.
*   **Seccomp Profile:** Enforce the `RuntimeDefault` seccomp profile.

### 5. Static Analysis (Checkov Settings)
*   **Frameworks:** Enable `terraform`, `kubernetes`, `helm`, `dockerfile`, and `secrets` frameworks.
*   **Module Inspection:** Enable `--download-external-modules true` to verify deep security posture and module pinning.
*   **Path Exclusions:** Always skip `state-credentials.tf` (generated) and `.external_modules` (third-party) to avoid false positives.
*   **Policy Gating:** Block plans that contain `CRITICAL` or `HIGH` severity findings related to IAM, Networking, or Runtime Security.
