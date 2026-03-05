resource "random_id" "pool_suffix" {
	byte_length=2
}

locals {
	# checkov:skip=CKV_SECRET_6:False positives for high entropy strings (OCI URLs and Regexes)

	allowed_github_repos=compact([
		var.liferay_workspace_git_repo_path
	])
	cluster_name="${var.deployment_name}-gke"
	common_labels={
		"app.kubernetes.io/component"="gitops-infrastructure"
		"app.kubernetes.io/managed-by"=local.terraform_manager_name
		"app.kubernetes.io/part-of"="liferay-gitops"
		"environment"="internal"
		"liferay.com/project"="liferay-cloud-native"
	}
	# Unique suffix using random_id to bypass GCP's 30-day soft-delete lock on names
	github_workload_identity_pool_name="${var.github_workload_identity_pool_id}-${random_id.pool_suffix.hex}"
	
	git_repo_auth_configs=merge(
		local.git_repo_infrastructure_separate_from_liferay ? {
			"infrastructure"=merge(
				var.infrastructure_git_repo_config.auth,
				{
					method=var.liferay_git_repo_auth_method
					secret_store_name="infrastructure-git-repo-credentials-vault"
					secret_store_provider_hcl=(
						var.infrastructure_git_repo_config.auth.secret_store_provider_hcl == null
						? local.git_repo_secret_store_provider_default
						: var.infrastructure_git_repo_config.auth.secret_store_provider_hcl
					)
					url=local.infrastructure_git_repo_url
			})
		} : {},
		{
			"liferay"=merge(
				var.liferay_git_repo_config.auth,
				{
					method=var.liferay_git_repo_auth_method
					secret_store_name="liferay-git-repo-credentials-vault"
					secret_store_provider_hcl=var.liferay_git_repo_config.auth.secret_store_provider_hcl == null ? local.git_repo_secret_store_provider_default : var.liferay_git_repo_config.auth.secret_store_provider_hcl
					url=var.liferay_git_repo_url
			})
		}
	)
	git_repo_infrastructure_separate_from_liferay=local.infrastructure_git_repo_url != var.liferay_git_repo_url
	git_repo_secret_store_provider_default={
		gcpsm={
			# The operator pod will now use its own KSA (linked to your GSA)
			projectID=var.project_id
		}
	}
	git_repo_secret_store_provider_default_enabled=(
		var.infrastructure_git_repo_config.auth.secret_store_provider_hcl == null ||
		var.liferay_git_repo_config.auth.secret_store_provider_hcl == null
	)
	infrastructure_appproject_name="liferay-infrastructure"
	infrastructure_git_repo_url=coalesce(var.infrastructure_git_repo_config.url, var.liferay_git_repo_url)
	liferay_appproject_name="liferay-application"
	liferay_helm_chart_config=merge(
		{
			version=var.liferay_helm_chart_version
		},
		var.liferay_helm_chart_name == "liferay-default" ? {
			name="liferay-default"
			region=var.region
			source_chart_value="liferay-default"
			source_repo_url_value="oci://us-central1-docker.pkg.dev/liferay-artifact-registry/liferay-helm-chart/liferay-default"
			values_scope_prefix=""
		} : {},
		var.liferay_helm_chart_name == "liferay-gcp" ? {
			name="liferay-gcp"
			path=var.liferay_gcp_helm_chart_config.path
			region=var.region
			source_chart_value="liferay-gcp"
			source_repo_url_value=var.liferay_gcp_helm_chart_config.image_url
			values_scope_prefix="liferay-default."
			version=var.liferay_gcp_helm_chart_config.version
		} : {},
	)
	liferay_service_account_role_name="${var.deployment_name}-gsa-role"
	oidc_provider="${var.project_id}.svc.id.goog"
	overlay_bucket_prefix=substr(var.project_id, 0, 15)
	overlay_bucket_suffix="-overlay"
	projectId=var.project_id
	project_number=data.google_project.project.number
	terraform_manager_name="liferay-cloud-native-terraform"
}
