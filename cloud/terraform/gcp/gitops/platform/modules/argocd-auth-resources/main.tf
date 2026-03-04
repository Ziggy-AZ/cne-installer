data "google_secret_manager_secret_version" "github_id" {
	secret=var.argocd_auth_config.github.client_id_secret_name
}

data "google_secret_manager_secret_version" "github_secret" {
	secret=var.argocd_auth_config.github.client_secret_secret_name
}

output "auth_helm_values" {
	value=yamlencode({
		configs ={
			cm={
				"admin.enabled"="false"
				"dex.config"=yamlencode({
					connectors =[{
						type="github"
						id="github"
						name="GitHub"
						config={
							clientID="$dex.github.clientID"
							clientSecret="$dex.github.clientSecret"
							orgs =[{
								name=var.argocd_auth_config.github.org
								teams =var.argocd_auth_config.github.teams
							}]
						}
					}]
				})
			}
			rbac={
				create=true
				"policy.csv"=join("\n", concat(
					[for team in var.argocd_auth_config.github.teams : "g, ${var.argocd_auth_config.github.org}:${team}, role:admin"],
					[for user in var.argocd_auth_config.rbac.admins : "g, ${user}, role:admin"],
					["p, role:admin, applications, action/argoproj.io/Application/wipe-infrastructure, *, allow"],
					["p, role:admin, applications, action/argoproj.io/Application/restore-infrastructure, *, allow"]
				))
				"scopes"="[email, groups]"
			}
			secret={
				extra={
					"dex.github.clientID"=data.google_secret_manager_secret_version.github_id.secret_data
					"dex.github.clientSecret"=data.google_secret_manager_secret_version.github_secret.secret_data
				}
			}
		}
	})
}
