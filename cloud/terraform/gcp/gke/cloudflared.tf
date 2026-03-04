module "cloudflare" {
	count=var.enable_cloudflare ? 1 : 0
	source="./modules/cloudflare"

	cloudflare_account_id=var.cloudflare_account_id
	cloudflare_zone_id=var.cloudflare_zone_id
	deployment_name=var.deployment_name
	domains =var.domains
}
