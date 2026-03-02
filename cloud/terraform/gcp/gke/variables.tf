variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  default = "us-central1"
}

variable "node_zones" {
  description = "The zones where the GKE cluster nodes should be located. If empty, the cluster will be spread across all zones in the region."
  type        = list(string)
  default     = []
}

variable "deployment_name" {
  default = "liferay-gcp"
  validation {
    condition     = can(regex("^[a-z0-9-]*$", var.deployment_name))
    error_message = "The deployment_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "deployment_namespace" {
  default = "liferay-system"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# GKE requires secondary ranges
variable "pod_cidr" {
  default = "10.1.0.0/16"
}

variable "service_cidr" {
  default = "10.2.0.0/16"
}

variable "demo_mode" {
  default = false
  type    = bool
}

# Kept for compatibility, though usually unused in GCP if using Artifact Registry in the same project
variable "ecr_repositories" {
  type    = map(object({ arn = string, url = string }))
  default = {}
}

variable "authorized_ipv4_cidr_block" {
  description = "The CIDR block for GKE Master Authorized Networks. If empty, authorized networks will be disabled."
  type        = string
  default     = ""
}


variable "networking_mode" {
  description = "Set to 'ingress' for legacy NGINX or 'gateway' for modern Envoy"
  type        = string
  default     = "gateway"
}

variable "domains" {
  description = "List of root domains to support. If empty, the cluster will be created without custom domain routing."
  type        = list(string)
  default     = []
}

variable "enable_cloudflare" {
  type        = bool
  default     = false
  description = "Whether to enable Cloudflare Zero Trust Tunnel and DNS management"
}

variable "enable_netbird" {
  type        = bool
  default     = false
  description = "Whether to enable NetBird Reverse Proxy"
}

variable "cloudflare_account_id" {
  type      = string
  default   = ""
  sensitive = true
}

variable "cloudflare_zone_id" {
  type    = string
  default = ""
}
