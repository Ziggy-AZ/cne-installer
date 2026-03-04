variable "project_id" {
	type=string
	description="The Google Cloud Project ID"
}

variable "region" {
	type=string
	description="The GCP region"
	default="us-central1"
}

variable "deployment_name" {
	type=string
	description="Deployment name, used for GKE cluster identification"
}

variable "spot" {
	type=bool
	description="Enable spot node policy"
	default=true
}

variable "kyverno_namespace" {
	type=string
	default="kyverno"
}
