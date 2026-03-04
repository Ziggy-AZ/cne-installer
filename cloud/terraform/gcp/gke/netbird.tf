module "netbird" {
	count=var.enable_netbird ? 1 : 0
	source="./modules/netbird"

	netbird_proxy_token=data.google_secret_manager_secret_version.netbird_proxy_token[0].secret_data
	deployment_name=var.deployment_name
	namespace="infra"
}
