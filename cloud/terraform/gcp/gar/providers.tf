provider "google" {
	project=var.project_id
	region=var.region
	default_labels ={
		deployment_name=var.deployment_name
	}
}

terraform {
	required_providers {
		google={
			source="hashicorp/google"
			version="~> 7.0"
		}
	}
}