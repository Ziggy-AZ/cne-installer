resource "google_project_iam_member" "node_permissions" {
	for_each=toset([
		"roles/artifactregistry.reader",
		"roles/logging.logWriter",
		"roles/monitoring.metricWriter",
	])
	member="serviceAccount:${google_service_account.node_sa.email}"
	project=var.project_id
	role=each.key
}
resource "google_service_account" "node_sa" {
	account_id="${var.deployment_name}-node-sa"
	display_name="GKE Node Service Account"
	project=var.project_id
}
module "gke" {
	cluster_resource_labels={
		deployment_name=var.deployment_name
		managed_by="terraform",
	}
	create_service_account=false
	deletion_protection=false
	depends_on=[module.vpc]
	enable_private_endpoint=false
	enable_private_nodes=true
	horizontal_pod_autoscaling=true
	http_load_balancing=true
	identity_namespace="enabled"
	ip_range_pods="${var.deployment_name}-pods"
	ip_range_services="${var.deployment_name}-services"
	master_authorized_networks=var.authorized_ipv4_cidr_block != "" ? [
		{
			cidr_block=var.vpc_cidr
			display_name="VPC-Internal",
		},
		{
			cidr_block=var.authorized_ipv4_cidr_block
			display_name="User-Authorized-Access",
		},
	] : []
	master_ipv4_cidr_block=var.master_ipv4_cidr_block
	name="${var.deployment_name}-gke"
	network=module.vpc.network_name
	project_id=var.project_id
	region=var.region
	regional=true
	service_account=google_service_account.node_sa.email
	source="git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/beta-autopilot-private-cluster?ref=1f95a655a3bcc1b35f37bf9df8f598a8bedfbf06"
	subnetwork=module.vpc.subnets_names[0]
	zones=var.node_zones
}
