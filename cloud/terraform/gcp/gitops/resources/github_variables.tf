# ---------------------------------------------------------------------------------------------------------------------
# AUTOMATIC GITHUB ACTIONS VARIABLES FOR WORKSPACE
# ---------------------------------------------------------------------------------------------------------------------
# These are configuration values, not secrets. Using Variables instead of Secrets 
# follows the Principle of Least Privilege by reducing the App's required permissions.

locals {
  workspace_vars = var.liferay_workspace_git_repo_url != "" ? {
    GCP_PROJECT_ID                 = var.project_id
    GCP_REGION                     = var.region
    GCP_WORKLOAD_IDENTITY_PROVIDER = google_iam_workload_identity_pool_provider.github.name
    GCP_GAR_REPOSITORY             = data.google_artifact_registry_repository.liferay_registry.name
    GCS_BUCKET_PREFIX              = local.overlay_bucket_prefix
  } : {}
}

resource "github_actions_variable" "workspace_vars" {
  for_each      = local.workspace_vars
  repository    = var.liferay_workspace_git_repo_path
  variable_name = each.key
  value         = each.value
}
