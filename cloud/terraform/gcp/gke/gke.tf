# ---------------------------------------------------------------------------------------------------------------------
# 1. SERVICE ACCOUNT FOR NODES
# ---------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "node_sa" {
  account_id   = "${var.deployment_name}-node-sa"
  display_name = "GKE Node Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "node_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.node_sa.email}"
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. GKE CLUSTER MODULE (AUTOPILOT)
# ---------------------------------------------------------------------------------------------------------------------
module "gke" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/beta-autopilot-private-cluster?ref=1f95a655a3bcc1b35f37bf9df8f598a8bedfbf06"

  project_id = var.project_id
  name       = "${var.deployment_name}-gke"
  region     = var.region

  regional = true # Autopilot is always regional
  zones    = var.node_zones

  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = "${var.deployment_name}-pods"
  ip_range_services = "${var.deployment_name}-services"

  identity_namespace = "enabled"

  cluster_resource_labels = {
    deployment_name = var.deployment_name
    managed_by      = "terraform"
  }

  create_service_account = false
  service_account        = google_service_account.node_sa.email

  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  deletion_protection        = false

  enable_private_nodes    = true
  enable_private_endpoint = false

  # Resolves the 10.0.0.0/28 CIDR conflict
  master_ipv4_cidr_block = "172.16.0.0/28"

  master_authorized_networks = var.authorized_ipv4_cidr_block != "" ? [
    {
      cidr_block   = var.authorized_ipv4_cidr_block
      display_name = "Authorized-Access"
    }
  ] : []

  depends_on = [module.vpc]
}


# ---------------------------------------------------------------------------------------------------------------------
# 3. WORKLOAD IDENTITY & STORAGE CLASS
# ---------------------------------------------------------------------------------------------------------------------
resource "google_service_account" "liferay_sa" {
  account_id   = "${var.deployment_name}-sa"
  display_name = "Liferay Workload Service Account"
  project      = var.project_id
}

resource "google_service_account_iam_member" "liferay_wi_binding" {
  service_account_id = google_service_account.liferay_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.deployment_namespace}/liferay-default]"
  depends_on         = [module.gke]
}
