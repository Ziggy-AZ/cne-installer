resource "helm_release" "argocd" {
	chart="argo-cd"
	create_namespace=false
	depends_on=[
		kubernetes_namespace.argocd
	]
	name="argocd"
	namespace=var.argocd_namespace
	repository="https://argoproj.github.io/argo-helm"
	upgrade_install=true
	values=[
		yamlencode(
			{
				applicationSet={
					resources={
						limits={
							cpu="500m"
							memory="1Gi"
						}
						requests={
							cpu="250m"
							memory="512Mi"
						}
					}
				}

				configs={
					cm={
						"application.allowedNodeLabels"="cloud.google.com/gke-spot,cloud.google.com/gke-compute-class,node.kubernetes.io/instance-type,topology.kubernetes.io/zone"
						"application.resourceTrackingMethod"="annotation"
						"resource.customizations.health.gcp.liferay.com_LiferayInfrastructure"=templatefile(
							"${path.module}/liferayinfrastructure-health-check.lua",
							{}
						)
						"resource.exclusions"=yamlencode(
							[
								{
									apiGroups=["*"]
									kinds=["ProviderConfigUsage"]
								},
								{
									apiGroups=["apiextensions.crossplane.io"]
									kinds=["ManagedResourceDefinition"]
								},
						])
					}
					params={
						"server.insecure"=true
					}
					rbac={
						create=false
					}
					secret={
						extra={
							"server.secretkey"=random_password.argocd_server_secretkey.result
							"webhook.github.secret"=var.argocd_github_webhook_config.enable_webhook ? data.google_secret_manager_secret_version.github_webhook[0].secret_data : ""
						}
					}
				}

				controller={
					resources={
						limits={
							cpu="1000m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
				}

				global={
					domain=var.argocd_domain != "" ? var.argocd_domain : null
					logging={
						format="json"
						level="info"
					}
				}

				installCRDs=true

				notifications={
					resources={
						limits={
							cpu="200m"
							memory="256Mi"
						}
						requests={
							cpu="100m"
							memory="128Mi"
						}
					}
				}

				redis={
					resources={
						limits={
							cpu="500m"
							memory="512Mi"
						}
						requests={
							cpu="200m"
							memory="256Mi"
						}
					}
				}

				repoServer={
					resources={
						limits={
							cpu="1000m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
				}

				server={
					extraArgs=["--insecure"]
					livenessProbe={
						initialDelaySeconds=90
						timeoutSeconds=5
					}
					readinessProbe={
						initialDelaySeconds=60
						timeoutSeconds=5
					}
					resources={
						limits={
							cpu="1000m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
					service={
						type="ClusterIP"
					}
				}
		}),
		var.argocd_auth_config.enable_sso ? module.argocd_auth_resources[0].auth_helm_values : "{}",
		var.enable_argocd_ui_tools ? module.argocd_ui_tools[0].argocd_ui_tools_helm_values : "{}"
	]
	version="9.4.4"
	wait=true
}

data "google_secret_manager_secret_version" "github_webhook" {
	count=var.argocd_github_webhook_config.enable_webhook ? 1 : 0
	secret=var.argocd_github_webhook_config.webhook_secret_name
}

resource "kubernetes_namespace" "argocd" {
	metadata {
		labels=local.common_labels
		name=var.argocd_namespace
	}
}

resource "random_password" "argocd_server_secretkey" {
	length=32
	special=false
}

module "argocd_auth_resources" {
	argocd_auth_config=var.argocd_auth_config
	count=var.argocd_auth_config.enable_sso ? 1 : 0
	source="./modules/argocd-auth-resources"
}

module "argocd_ui_tools" {
	count=var.enable_argocd_ui_tools ? 1 : 0
	source="./modules/argocd-ui-tools"
}
