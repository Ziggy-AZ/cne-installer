# ---------------------------------------------------------
# DIRECT IAM ACCESS FOR EXTERNAL SECRETS OPERATOR (ESO)
# ---------------------------------------------------------
# Instead of an intermediate GSA, we grant Secret Accessor permissions
# directly to the ESO Kubernetes Service Account using Direct Workload Identity.

resource "google_project_iam_member" "secrets_accessor_permissions" {
  count   = local.git_repo_secret_store_provider_default_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"

  # The principal format for direct KSA binding using the ns/sa hierarchy
  member = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.external_secrets_namespace}/sa/external-secrets"
}
