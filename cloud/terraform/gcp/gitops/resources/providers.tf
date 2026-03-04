provider "google" {
	project=var.project_id
	region=var.region
}

data "google_container_cluster" "primary" {
	name="${var.deployment_name}-gke"
	location=var.region
}

provider "kubernetes" {
	host="https://${data.google_container_cluster.primary.endpoint}"
	token=data.google_client_config.default.access_token
	cluster_ca_certificate=base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
	kubernetes ={
		host="https://${data.google_container_cluster.primary.endpoint}"
		token=data.google_client_config.default.access_token
		cluster_ca_certificate=base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
	}
}

provider "github" {
	owner=var.liferay_workspace_git_repo_path != "" ? split("/", var.liferay_workspace_git_repo_path)[0] : "unknown"
	app_auth {
		id=var.liferay_workspace_git_repo_path != "" ? jsondecode(data.google_secret_manager_secret_version.github_app_creds[0].secret_data).github_app_id : "0"
		installation_id=var.liferay_workspace_git_repo_path != "" ? jsondecode(data.google_secret_manager_secret_version.github_app_creds[0].secret_data).github_app_installation_id : "0"
		pem_file=var.liferay_workspace_git_repo_path != "" ? jsondecode(data.google_secret_manager_secret_version.github_app_creds[0].secret_data).github_app_private_key : "empty"
	}
}

terraform {
	required_providers {
		google={
			source="hashicorp/google"
			version="~> 7.0"
		}
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		kubernetes ={
			source="hashicorp/kubernetes"
			version="~> 2.36.0"
		}
		github={
			source="integrations/github"
			version="~> 6.0"
		}
	}
	required_version=">=1.5.0"
}
