# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL ADVANCED CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

# Authorized Networks: Restrict GKE API access to your specific IP address.
# Example: "1.2.3.4/32"
# authorized_ipv4_cidr_block = ""

# Custom Domains: Provide a list of domains for routing.
# Example: ["example.com", "myportal.io"]
# domains = []

# GKE Node Zones: Specify the zones for the GKE cluster. If empty, it uses all zones in the region.
# Example: ["us-central1-a", "us-central1-b"]
# node_zones = []

# GitOps Repository: The URL of your own GitOps repository (created from the template).
liferay_git_repo_url = ""

# Liferay Workspace Repository: The URL of your separate workspace repo (for Overlay).
# Example: "my-org/liferay-workspace"
liferay_workspace_git_repo_url = ""

# GitOps Auth Method: 'https' (default), 'ssh', or 'github_app'.
# liferay_git_repo_auth_method = "https"

# Root Domain: The primary domain for your Liferay deployment.
root_domain = ""

# ArgoCD Domain: Specifically for accessing the ArgoCD UI.
# argocd_domain = "argocd.example.com"

# ArgoCD Auth: Enable GitHub SSO and RBAC.
# argocd_auth_config = {
#   enable_sso = true
#   github = {
#     org   = "your-github-org"
#     teams = ["your-admin-team"]
#   }
#   rbac = {
#     admins = ["your-github-username"]
#   }
# }

# ArgoCD Webhook: Enable instant syncing on GitHub push.
# argocd_github_webhook_config = {
#   enable_webhook = true
# }

# Cloudflare Integration: Enable Zero Trust Tunneling and DNS management.
# enable_cloudflare     = false
# cloudflare_account_id = ""
# cloudflare_zone_id    = ""

# NetBird Integration: Enable NetBird Reverse Proxy.
# enable_netbird = false

# Artifact Registry Public Access (Optional)
# enable_public_gar_access = false

# ---------------------------------------------------------------------------------------------------------------------
# AUTOMATED SETTINGS
# (Do not edit these manually; they are handled by the installer)
# ---------------------------------------------------------------------------------------------------------------------
# project_id   = ""
# region       = ""
# liferay_helm_chart_version = ""
# github_workload_identity_pool_id = ""
