variable "authorized_ipv4_cidr_block" {
	default=""
	type=string
}

variable "cloudflare_account_id" {
	default=""
	sensitive=true
	type=string
}

variable "cloudflare_zone_id" {
	default=""
	type=string
}

variable "demo_mode" {
	default=false
	type=bool
}

variable "deployment_name" {
	default="liferay-gcp"
	validation {
		condition=can(regex("^[a-z0-9-]*$", var.deployment_name))
		error_message="The deployment_name must contain only lowercase letters, numbers, and hyphens."
	}
}

variable "deployment_namespace" {
	default="liferay-system"
}

variable "domains" {
	default=[]
	type=list(string)
}

# Kept for compatibility, though usually unused in GCP if using Artifact Registry in the same project
variable "ecr_repositories" {
	default={}
	type=map(object({ arn=string, url=string }))
}

variable "enable_cloudflare" {
	default=false
	type=bool
}

variable "enable_netbird" {
	default=false
	type=bool
}

variable "master_ipv4_cidr_block" {
	default="172.16.0.0/28"
}

variable "networking_mode" {
	default="gateway"
	type=string
}

variable "node_zones" {
	default=[]
	type=list(string)
}

# GKE requires secondary ranges
variable "pod_cidr" {
	default="10.1.0.0/16"
}

variable "project_id" {
	type=string
}

variable "region" {
}

variable "service_cidr" {
	default="10.2.0.0/16"
}

variable "vpc_cidr" {
	default="10.0.0.0/16"
}
