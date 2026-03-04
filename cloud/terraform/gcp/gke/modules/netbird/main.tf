# NetBird Reverse Proxy Deployment
resource "kubernetes_deployment_v1" "netbird_proxy" {
	metadata {
		name="netbird-reverse-proxy"
		namespace=var.namespace
		labels ={
			app="netbird-proxy"
		}
	}

	spec {
		replicas =1

		selector {
			match_labels ={
				app="netbird-proxy"
			}
		}

		template {
			metadata {
				labels ={
					app="netbird-proxy"
				}
			}

			spec {
				container {
					name="proxy"
					image="netbirdio/reverse-proxy:latest"

					env {
						name="NETBIRD_PROXY_TOKEN"
						value=var.netbird_proxy_token
					}

					# The proxy will connect to the internal Envoy gateway
					# Note: NetBird Dashboard handles the actual mapping of public domains
					# to this internal target.

					resources {
						limits ={
							cpu="500m"
							memory="512Mi"
						}
						requests ={
							cpu="100m"
							memory="128Mi"
						}
					}
				}
			}
		}
	}
}
