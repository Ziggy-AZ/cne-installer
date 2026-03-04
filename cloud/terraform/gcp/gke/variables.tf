variable "authorized_ipv4_cidr_block" {
	default=""
	description="The CIDR block for GKE Master Authorized Networks. If empty, authorized networks will be disabled."
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
	description="List of root domains to support. If empty, the cluster will be created without custom domain routing."
	type=list(string)
}

# Kept for compatibility, though usually unused in GCP if using Artifact Registry in the same project
variable "ecr_repositories" {
	default={}
	type=map(object({ arn=string, url=string }))
}

variable "enable_cloudflare" {
	default=false
	description="Whether to enable Cloudflare Zero Trust Tunnel and DNS management"
	type=bool
}

variable "enable_netbird" {
	default=false
	description="Whether to enable NetBird Reverse Proxy"
	type=bool
}

variable "networking_mode" {
	default="gateway"
	description="Set to 'ingress' for legacy NGINX or 'gateway' for modern Envoy"
	type=string
}

variable "node_zones" {
	default=[]
	description="The zones where the GKE cluster nodes should be located. If empty, the cluster will be spread across all zones in the region."
	type=list(string)
}

# GKE requires secondary ranges
variable "pod_cidr" {
	default="10.1.0.0/16"
}

variable "project_id" {
	description="The GCP Project ID"
	type=string
}

variable "region" {
	default="us-central1"
}

variable "service_cidr" {
	default="10.2.0.0/16"
}

variable "vpc_cidr" {
	default="10.0.0.0/16"
}
