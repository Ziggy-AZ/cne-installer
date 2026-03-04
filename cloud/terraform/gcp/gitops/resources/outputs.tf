output "github_workload_identity_pool_id" {
	value=google_iam_workload_identity_pool.github.workload_identity_pool_id
	description="The ID of the GitHub Workload Identity Pool"
}

output "github_workload_identity_pool_name" {
	value=google_iam_workload_identity_pool.github.name
	description="The full name of the GitHub Workload Identity Pool"
}

output "github_workload_identity_provider_name" {
	value=google_iam_workload_identity_pool_provider.github.name
	description="VALUE FOR: GCP_WORKLOAD_IDENTITY_PROVIDER"
}

output "artifact_registry_repo_name" {
	value=data.google_artifact_registry_repository.liferay_registry.name
	description="VALUE FOR: GCP_GAR_REPOSITORY"
}

output "overlay_bucket_prefix" {
	value=local.overlay_bucket_prefix
	description="Prefix for GCS_BUCKET_NAME (e.g. [prefix]-[env]-overlay)"
}
