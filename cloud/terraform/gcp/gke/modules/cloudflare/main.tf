# 1. Generate a random secret for the tunnel password
resource "random_id" "tunnel_secret" {
	byte_length=32
}

# 2. Create the Zero Trust Tunnel
resource "cloudflare_zero_trust_tunnel_cloudflared" "gke_tunnel" {
	account_id=var.cloudflare_account_id
	name="${var.deployment_name}-tunnel"
	tunnel_secret=random_id.tunnel_secret.b64_std
	config_src="cloudflare"
}

# 3. Fetch the Tunnel Token via Data Source
data "cloudflare_zero_trust_tunnel_cloudflared_token" "gke_tunnel_token" {
	account_id=var.cloudflare_account_id
	tunnel_id=cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id
}

# 4. Ingress Configuration
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "gke_tunnel_config" {
	account_id=var.cloudflare_account_id
	tunnel_id=cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id

	config={
		ingress =concat(
			[for d in var.domains : {
				hostname=d
				service="http://envoy-internal-proxy.infra.svc.cluster.local:80"
			}],
			[for d in var.domains : {
				hostname="*.${d}"
				service="http://envoy-internal-proxy.infra.svc.cluster.local:80"
			}],
			[{
				service="http_status:404"
			}]
		)
	}
}

# 5. DNS Records
resource "cloudflare_dns_record" "root_dns" {
	for_each=toset(var.domains)
	zone_id=var.cloudflare_zone_id
	name=each.value
	type="CNAME"
	content="${cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id}.cfargotunnel.com"
	proxied=true
	ttl=1
}

resource "cloudflare_dns_record" "wildcard_dns" {
	for_each=toset(var.domains)
	zone_id=var.cloudflare_zone_id
	name="*.${each.value}"
	type="CNAME"
	content="${cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id}.cfargotunnel.com"
	proxied=true
	ttl=1
}

# 7. Deploy the Tunnel Agent
resource "helm_release" "cloudflare_tunnel" {
	name="cloudflare-tunnel-remote"
	repository="https://cloudflare.github.io/helm-charts"
	chart="cloudflare-tunnel-remote"
	namespace="infra"
	create_namespace=true

	set_sensitive=[
		{
			name="cloudflare.tunnel_token"
			value=data.cloudflare_zero_trust_tunnel_cloudflared_token.gke_tunnel_token.token
		},
		{
			name="image.tag"
			value="2026.2.0"
		}
	]

	values =[
		yamlencode({
			resources ={
				limits ={
					cpu="200m"
					memory="256Mi"
				}
				requests ={
					cpu="100m"
					memory="128Mi"
				}
			}
		})
	]
}
