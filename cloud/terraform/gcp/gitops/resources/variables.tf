variable "argocd_namespace" {
	default="argocd"
	type=string
}
variable "crossplane_namespace" {
	default="crossplane-system"
	type=string
}
variable "deployment_name" {
	validation {
		condition=can(regex("^[a-z0-9-]*$", var.deployment_name))
		error_message="The deployment_name must contain only lowercase letters, numbers, and hyphens."
	}
	default="liferay-gcp"
}
variable "external_secrets_namespace" {
	default="external-secrets"
	type=string
}
variable "infrastructure_git_repo_config" {
	default={
		auth={}
		source_paths ={}
		target={}
	}
	type=object(
		{
			auth=object({
				internal_secret_name=optional(string, "argocd-infrastructure-git-credentials")
				method=optional(string, "https")
				secret_store_provider_hcl=optional(any, null)
				ssh_private_key_vault_secret_property=optional(string, "git_ssh_private_key")
				token_vault_secret_property=optional(string, "git_access_token")
				username_vault_secret_property=optional(string, "git_machine_user_id")
				github_app_id_vault_secret_property=optional(string, "github_app_id")
				github_app_install_id_vault_secret_property=optional(string, "github_app_installation_id")
				github_app_key_vault_secret_property=optional(string, "github_app_private_key")
				// no slashes allowed
				vault_secret_name=optional(string, "liferay-cloud-native-gitops-repo-credentials")
			})
			revision=optional(string, "HEAD")
			source_paths =object({
				base=optional(string, "liferay/projects/{{path[2]}}/base")
				environments =optional(string, "liferay/projects/*/environments/*")
				values_filename=optional(string, "infrastructure.yaml")
			})
			target=object({
				name=optional(string, "{{path[2]}}-{{path[4]}}-infra")
				namespaceSuffix=optional(string, "{{path[2]}}-{{path[4]}}")
				slugEnvironmentId=optional(string, "{{path[4]}}")
				slugProjectId=optional(string, "{{path[2]}}")
			})
			url=optional(string, null)
	})
	validation {
		condition=(
			!contains(keys(var.infrastructure_git_repo_config.auth), "method") ||
		contains(["https", "ssh", "github_app"], var.infrastructure_git_repo_config.auth.method))
		error_message="The 'infrastructure_git_repo_auth_config.method' value must be 'https', 'ssh', or 'github_app'."
	}
}

variable "liferay_gcp_helm_chart_config" {
	default={}
	type=object(
		{
			image_name=optional(string, "liferay-gcp")
			image_url=optional(string, "oci://us-central1-docker.pkg.dev/gcp-liferay/liferay-deployment-registry/liferay-gcp")
			version=optional(string, "0.1.6")
			path=optional(string)
	})
}

variable "infrastructure_helm_chart_config" {
	default={}
	type=object(
		{
			image_name=optional(string, "liferay-gcp-infrastructure")
			image_url=optional(string, "oci://us-central1-docker.pkg.dev/gcp-liferay/liferay-deployment-registry/liferay-gcp-infrastructure")
			version=optional(string, "0.1.6")
			path=optional(string)
	})
}

variable "infrastructure_provider_helm_chart_config" {
	default={}
	type=object(
		{
			image_name=optional(string, "liferay-gcp-infrastructure-provider")
			image_url=optional(string, "oci://us-central1-docker.pkg.dev/gcp-liferay/liferay-deployment-registry/liferay-gcp-infrastructure-provider")
			version=optional(string, "0.1.15")
			path=optional(string)
	})
}


variable "liferay_git_repo_config" {
	default={
		auth={}
		source_paths ={}
		target={}
	}
	type=object(
		{
			auth=object({
				internal_secret_name=optional(string, "argocd-liferay-git-credentials")
				method=optional(string, "https")
				secret_store_provider_hcl=optional(any, null)
				ssh_private_key_vault_secret_property=optional(string, "git_ssh_private_key")
				token_vault_secret_property=optional(string, "git_access_token")
				username_vault_secret_property=optional(string, "git_machine_user_id")
				github_app_id_vault_secret_property=optional(string, "github_app_id")
				github_app_install_id_vault_secret_property=optional(string, "github_app_installation_id")
				github_app_key_vault_secret_property=optional(string, "github_app_private_key")
				// No slashes allowed
				vault_secret_name=optional(string, "liferay-cloud-native-gitops-repo-credentials")
			})
			revision=optional(string, "HEAD")
			source_paths =object({
				base=optional(string, "liferay/projects/{{path[2]}}/base")
				environments =optional(string, "liferay/projects/*/environments/*")
				values_filename=optional(string, "liferay.yaml")
			})
			target=object({
				name=optional(string, "{{path[2]}}-{{path[4]}}-app")
				namespaceSuffix=optional(string, "{{path[2]}}-{{path[4]}}")
				slugEnvironmentId=optional(string, "{{path[4]}}")
				slugProjectId=optional(string, "{{path[2]}}")
			})
	})
	validation {
		condition=(
			!contains(keys(var.liferay_git_repo_config.auth), "method") ||
		contains(["https", "ssh", "github_app"], var.liferay_git_repo_config.auth.method))
		error_message="The 'liferay_git_repo_auth_config.method' value must be 'https', 'ssh', or 'github_app'."
	}
}
variable "liferay_git_repo_url" {
	type=string
}
variable "liferay_workspace_git_repo_path" {
	type=string
	default=""
	description="The GitHub repository path in 'owner/repo' format (e.g. Ziggy-AZ/cne-workspace)."
}

variable "liferay_git_repo_auth_method" {
	type=string
	default="https"
}
variable "liferay_helm_chart_name" {
	default="liferay-gcp"
	type=string
	validation {
		condition=contains(
			[
				"liferay-default",
				"liferay-gcp",
			],
		var.liferay_helm_chart_name)
		error_message="The 'liferay_helm_chart_name' value must be 'liferay-default' or 'liferay-gcp'."
	}
}
variable "liferay_helm_chart_version" {
	type=string
}
variable "region" {
	default="us-central1"
}

variable "github_workload_identity_pool_id" {
	type=string
	description="The ID of the GitHub Workload Identity Pool"
	default="github-pool"
}

variable "project_id" {
	type=string
}

variable "root_domain" {
	type=string
}

