# 1. Fetch current Google Project metadata (Project ID, Project Number) 
data "google_project" "project" {}

# 2. Get the current GCP client configuration (used for OAuth2 tokens) 
data "google_client_config" "default" {}

# 3. (Optional) Fetch VPC details if you need to reference them for Crossplane 
# This assumes your VPC name matches your deployment name
data "google_compute_network" "vpc" {
	name="${var.deployment_name}-vpc"
}

# 4. (Optional) Fetch subnets if needed for specific platform services 
data "google_compute_subnetwork" "private_subnet" {
	name="${var.deployment_name}-subnet"
	region=var.region
}

data "google_artifact_registry_repository" "liferay_registry" {
	location=var.region
	repository_id="${var.deployment_name}-registry"
}

data "google_secret_manager_secret_version" "github_app_creds" {
	count=var.liferay_workspace_git_repo_path != "" ? 1 : 0
	secret=var.liferay_git_repo_config.auth.vault_secret_name
	version="latest"
}