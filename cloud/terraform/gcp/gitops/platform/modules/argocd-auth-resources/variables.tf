variable "argocd_auth_config" {
	type=object({
		enable_sso=optional(bool, false)
		github=optional(object({
			org=string
			teams =list(string)
			client_id_secret_name=optional(string, "github-client-id")
			client_secret_secret_name=optional(string, "github-client-secret")
		}))
		rbac=optional(object({
			admins =list(string)
		}))
	})
}