resource "google_project_service" "apis" {
	for_each=toset([
		"compute.googleapis.com",             # For VPC and Nodes
		"container.googleapis.com",           # For GKE
		"iam.googleapis.com",                 # For Service Accounts
		"artifactregistry.googleapis.com",    # For Images
		"cloudresourcemanager.googleapis.com" # Required for project updates
	])

	project=var.project_id
	service=each.key
	disable_on_destroy=false
}