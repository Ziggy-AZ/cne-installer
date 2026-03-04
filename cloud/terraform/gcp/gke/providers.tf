# Switches the provider to google and updates authentication for Helm/Kubernetes to use GKE.

provider "google" {
	project=var.project_id
	region=var.region
	default_labels ={
		deployment_name=var.deployment_name
	}
}

data "google_client_config" "default" {}

# 1. Fetch the API Token from GCP Secret Manager (if Cloudflare is enabled)
data "google_secret_manager_secret_version" "cloudflare_api_token" {
	count=var.enable_cloudflare ? 1 : 0
	secret="cloudflare-api-token"
	project=var.project_id
}

data "google_secret_manager_secret_version" "netbird_proxy_token" {
	count=var.enable_netbird ? 1 : 0
	secret="netbird-proxy-token"
	project=var.project_id
}

# 2. Configure the Cloudflare Provider using that token
provider "cloudflare" {
	# The provider requires a valid format even if not used. 
	# We provide a 40-char dummy string if Cloudflare is disabled.
	api_token=var.enable_cloudflare ? data.google_secret_manager_secret_version.cloudflare_api_token[0].secret_data : "0000000000000000000000000000000000000000"
}

provider "kubernetes" {
	host="https://${module.gke.endpoint}"
	token=data.google_client_config.default.access_token
	cluster_ca_certificate=base64decode(module.gke.ca_certificate)
}

provider "helm" {
	kubernetes ={
		host="https://${module.gke.endpoint}"
		token=data.google_client_config.default.access_token
		cluster_ca_certificate=base64decode(module.gke.ca_certificate)
	}
}

terraform {
	required_providers {
		google={
			source="hashicorp/google"
			version="~> 7.0"
		}
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		kubernetes ={
			source="hashicorp/kubernetes"
			version="~> 2.24"
		}
		random={
			source="hashicorp/random"
			version="~> 3.0"
		}
		time={
			source="hashicorp/time"
			version="~> 0.9"
		}
		cloudflare={
			source="cloudflare/cloudflare"
			version="~> 5.0"
		}
	}
	required_version=">= 1.5.0"
}
