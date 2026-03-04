variable "argo_cd_auth_config" {
	default={
		enable_sso=false
		github=null
		rbac=null
	}
	description="Configuration object for ArgoCD authentication and RBAC"
	type=object({
		enable_sso=optional(bool, false)
		github=optional(object({
			client_id_secret_name=optional(string, "github-client-id")
			client_secret_secret_name=optional(string, "github-client-secret")
			org=string
			teams=list(string)
		}))
		rbac=optional(object({
			admins=list(string)
		}))
	})
}

variable "argo_cd_domain" {
	default=""
	type=string
}

variable "argo_cd_github_webhook_config" {
	default={
		enable_webhook=false
		webhook_secret_name=""
	}
	description="Configuration object for ArgoCD authentication and RBAC"
	type=object({
		enable_webhook=optional(bool, false)
		webhook_secret_name=optional(string, "github-webhook-secret")
	})
}

variable "argo_cd_namespace" {
	default="argocd"
	type=string
}

variable "crossplane_namespace" {
	default="crossplane-system"
	type=string
}

variable "deployment_name" {
	default="liferay-gcp"
	type=string
}

variable "enable_argo_cd_ui_tools" {
	default=true
	type=bool
}

variable "external_secrets_namespace" {
	default="external-secrets"
	type=string
}

variable "project_id" {
	type=string
}

variable "region" {
	default="us-central1"
	type=string
}
