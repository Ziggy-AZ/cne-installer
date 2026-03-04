variable "cloudflare_account_id" {
	type=string
	description="Cloudflare Account ID"
}

variable "cloudflare_zone_id" {
	type=string
	description="Cloudflare Zone ID"
}

variable "deployment_name" {
	type=string
	description="Deployment name for resource naming"
}

variable "domains" {
	type=list(string)
	description="List of root domains to support"
}
