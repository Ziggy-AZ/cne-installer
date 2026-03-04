variable "netbird_proxy_token" {
	type=string
	description="The Proxy Token generated from the NetBird dashboard"
	sensitive=true
}

variable "deployment_name" {
	type=string
	description="Deployment name for resource naming"
}

variable "namespace" {
	type=string
	default="infra"
	description="Namespace to deploy the NetBird agent"
}
