# ---------------------------------------------------------
# 1. GSA for Cloud Platform Provider (Required for IAM management)
# ---------------------------------------------------------
# Upbound's cloudplatform provider currently only works with a 
# dedicated GSA for high-privilege IAM and Service Account operations.
# Extensive tests were done with a KSA but it fails with 400 errors due to 
# terms of service not being accepted: 
#       Caller must use first-party authentication in order to accept terms of service and use this API.

resource "google_service_account" "cloudplatform_gsa" {
  account_id   = "${var.deployment_name}-cp-iam"
  display_name = "Crossplane Cloud Platform GSA (IAM Management)"
  project      = var.project_id
}

locals {
  cloudplatform_roles = [
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin"
  ]
}

resource "google_project_iam_member" "cloudplatform_roles" {
  for_each = toset(local.cloudplatform_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.cloudplatform_gsa.email}"
}

resource "google_service_account_iam_member" "cloudplatform_wi_binding" {
  service_account_id = google_service_account.cloudplatform_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}/provider-gcp-cloudplatform]"
}

# ---------------------------------------------------------
# 2. Direct IAM Bindings for other Crossplane Providers
# ---------------------------------------------------------
# SQL, Storage, and Compute use the leaner Direct KSA pattern.

locals {
  ksa_principal_base = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.crossplane_namespace}/sa"
  
  direct_provider_ksas = {
    sql     = "roles/cloudsql.admin"
    compute = "roles/compute.admin"
    storage = "roles/storage.admin"
  }
}

resource "google_project_iam_member" "provider_direct_iam" {
  for_each = local.direct_provider_ksas

  project = var.project_id
  role    = each.value
  member  = "${local.ksa_principal_base}/provider-gcp-${each.key}"
}

# ---------------------------------------------------------
# 3. Crossplane Functions (Standard)
# ---------------------------------------------------------
resource "kubernetes_manifest" "function_auto_ready" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-auto-ready"
    }
    spec = {
      package = "xpkg.upbound.io/upbound/function-auto-ready:v0.6.0"
    }
  }
}

resource "kubernetes_manifest" "function_go_templating" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-go-templating"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.11.3"
    }
  }
}

resource "kubernetes_manifest" "function_environment_configs" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-environment-configs"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/function-environment-configs:v0.6.0"
    }
  }
  provider = kubernetes
}
