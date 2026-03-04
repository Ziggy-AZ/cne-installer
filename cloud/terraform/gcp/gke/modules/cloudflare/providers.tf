terraform {
	required_providers {
		cloudflare={
			source="cloudflare/cloudflare"
			version="~> 5.0"
		}
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		random={
			source="hashicorp/random"
			version="~> 3.0"
		}
	}
}
