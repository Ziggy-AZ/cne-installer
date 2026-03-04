resource "kubernetes_manifest" "infrastructure_applicationset" {
	depends_on=[
		kubernetes_manifest.git_repo_credentials_external_secret,
		kubernetes_manifest.infrastructure_appproject,
	]
	field_manager {
		force_conflicts =true
		name=local.terraform_manager_name
	}
	manifest={
		apiVersion="argoproj.io/v1alpha1"
		kind="ApplicationSet"
		metadata={
			finalizers =["resources-finalizer.argocd.argoproj.io"]
			labels =merge(
				local.common_labels,
				{
					"app.kubernetes.io/name"="liferay-infrastructure-applicationset"
			})
			name="liferay-infrastructure-applicationset"
			namespace=var.argocd_namespace
		}
		spec={
			generators =[
				{
					git={
						files =[
							{
								path="${var.infrastructure_git_repo_config.source_paths.environments}/${var.infrastructure_git_repo_config.source_paths.values_filename}"
							},
						]
						repoURL=local.infrastructure_git_repo_url
						revision=var.infrastructure_git_repo_config.revision
					}
				},
			]
			template={
				metadata={
					annotations ={
						"argocd.argoproj.io/compare-options"="IgnoreExtraneous"
					}
					name=var.infrastructure_git_repo_config.target.name
				}
				spec={
					destination={
						namespace="liferay-${var.infrastructure_git_repo_config.target.namespaceSuffix}"
						server="https://kubernetes.default.svc"
					}
					project=local.infrastructure_appproject_name
					sources =[
						merge(
							{
								helm={
									parameters =[
										{
											name="environmentId"
											value=var.infrastructure_git_repo_config.target.slugEnvironmentId
										},
										{
											name="projectId"
											value=var.infrastructure_git_repo_config.target.slugProjectId
										},
										{
											name="gcp.projectId"
											value=local.projectId
										},
										{
											name="gcp.projectNumber"
											value=local.project_number
										},
										{
											name="rootDomain"
											value=var.root_domain
										},
									]
									valueFiles =[
										"$values/${var.infrastructure_git_repo_config.source_paths.base}/${var.infrastructure_git_repo_config.source_paths.values_filename}",
										"$values/{{path}}/${var.infrastructure_git_repo_config.source_paths.values_filename}",
									]
								}
								repoURL=var.infrastructure_helm_chart_config.image_url
								targetRevision=var.infrastructure_helm_chart_config.version
							},
							var.infrastructure_helm_chart_config.path != null ? { path=var.infrastructure_helm_chart_config.path } : { chart=var.infrastructure_helm_chart_config.image_name }
						),
						{
							ref="values"
							repoURL=local.infrastructure_git_repo_url
							targetRevision=var.infrastructure_git_repo_config.revision
						},
					]
					syncPolicy={
						automated={
							prune=true
							selfHeal=true
						}
						syncOptions =[
							"CreateNamespace=true",
							"SkipDryRunOnMissingResource=true"
						]
					}
				}
			}
		}
	}
}
resource "kubernetes_manifest" "infrastructure_appproject" {
	field_manager {
		force_conflicts =true
		name=local.terraform_manager_name
	}
	manifest={
		apiVersion="argoproj.io/v1alpha1"
		kind="AppProject"
		metadata={
			name=local.infrastructure_appproject_name
			namespace=var.argocd_namespace
			labels =merge(
				local.common_labels,
				{
					"app.kubernetes.io/name"="infrastructure-appproject"
			})
		}
		spec={
			clusterResourceWhitelist=[
				{
					group="*"
					kind="*"
				},
			]
			description="ArgoCD Project for Liferay Cloud Native infrastructure."
			destinations =[
				{
					namespace="liferay-*"
					server="https://kubernetes.default.svc"
				},
				{
					namespace=var.crossplane_namespace
					server="https://kubernetes.default.svc"
				},
			]
			sourceRepos =[
				"${var.infrastructure_helm_chart_config.image_url}",
				"${var.infrastructure_helm_chart_config.image_url}/*",
				"${var.infrastructure_provider_helm_chart_config.image_url}",
				"${var.infrastructure_provider_helm_chart_config.image_url}/*",
				local.infrastructure_git_repo_url,
			]
		}
	}
}
resource "kubernetes_manifest" "infrastructure_provider_application" {
	depends_on=[
		kubernetes_manifest.git_repo_credentials_external_secret,
		kubernetes_manifest.infrastructure_appproject,
	]
	field_manager {
		force_conflicts =true
		name=local.terraform_manager_name
	}
	manifest={
		apiVersion="argoproj.io/v1alpha1"
		kind="Application"
		metadata={
			annotations ={
				"argocd.argoproj.io/compare-options"="IgnoreExtraneous"
			}
			finalizers =["resources-finalizer.argocd.argoproj.io"]
			labels =merge(
				local.common_labels,
				{
					"app.kubernetes.io/name"="liferay-infrastructure-provider"
			})
			name="liferay-infrastructure-provider"
			namespace=var.argocd_namespace
		}
		spec={
			destination={
				namespace=var.crossplane_namespace
				server="https://kubernetes.default.svc"
			}
			project=local.infrastructure_appproject_name
			source=merge(
				{
					helm={
						parameters =[
							{
								name="crossplaneNamespace"
								value=var.crossplane_namespace
							},
							{
								name="deploymentName"
								value=var.deployment_name
							},
							{
								name="gcp.clusterName"
								value=local.cluster_name
							},
							{
								name="gcp.networkName"
								value=data.google_compute_network.vpc.name
							},
							{
								name="gcp.projectId"
								value=local.projectId
							},
							{
								name="gcp.projectNumber"
								value=local.project_number
							},
							{
								name="gcp.subnetworkName"
								value=data.google_compute_subnetwork.private_subnet.name
							},
							{
								name="liferayServiceAccountRoleName"
								value=local.liferay_service_account_role_name
							},
							{
								name="rootDomain"
								value=var.root_domain
							},
						]
					}
					repoURL=var.infrastructure_provider_helm_chart_config.image_url
					targetRevision=var.infrastructure_provider_helm_chart_config.version
				},
				var.infrastructure_provider_helm_chart_config.path != null ? { path=var.infrastructure_provider_helm_chart_config.path } : { chart=var.infrastructure_provider_helm_chart_config.image_name }
			)
			syncPolicy={
				automated={
					prune=true
					selfHeal=true
				}
				syncOptions =[
					"CreateNamespace=true",
					"SkipDryRunOnMissingResource=true",
				]
			}
		}
	}
}
resource "kubernetes_manifest" "liferay_applicationset" {
	depends_on=[
		kubernetes_manifest.git_repo_credentials_external_secret,
		kubernetes_manifest.liferay_appproject,
	]
	field_manager {
		force_conflicts =true
		name=local.terraform_manager_name
	}
	manifest={
		apiVersion="argoproj.io/v1alpha1"
		kind="ApplicationSet"
		metadata={
			finalizers =["resources-finalizer.argocd.argoproj.io"]
			labels =merge(
				local.common_labels,
				{
					"app.kubernetes.io/name"="liferay-applicationset"
			})
			name="liferay-applicationset"
			namespace=var.argocd_namespace
		}
		spec={
			generators =[
				{
					git={
						files =[
							{
								path="${var.liferay_git_repo_config.source_paths.environments}/${var.liferay_git_repo_config.source_paths.values_filename}"
							},
						]
						repoURL=var.liferay_git_repo_url
						revision=var.liferay_git_repo_config.revision
					}
				},
			]
			template={
				metadata={
					annotations ={
						"argocd.argoproj.io/compare-options"="IgnoreExtraneous"
					}
					name=var.liferay_git_repo_config.target.name
				}
				spec={
					destination={
						namespace="liferay-${var.liferay_git_repo_config.target.namespaceSuffix}"
						server="https://kubernetes.default.svc"
					}
					project=local.liferay_appproject_name
					sources =[
						merge(
							{
								helm={
									parameters =[
										{
											name="${local.liferay_helm_chart_config.values_scope_prefix}environmentId"
											value=var.liferay_git_repo_config.target.slugEnvironmentId
										},
										{
											name="${local.liferay_helm_chart_config.values_scope_prefix}projectId"
											value=var.liferay_git_repo_config.target.slugProjectId
										},
										{
											name="${local.liferay_helm_chart_config.values_scope_prefix}serviceAccount.create"
											value=true
										},
										{
											name="rootDomain"
											value=var.root_domain
										},
									]
									valueFiles =[
										"$values/${var.liferay_git_repo_config.source_paths.base}/${var.liferay_git_repo_config.source_paths.values_filename}",
										"$values/{{path}}/${var.liferay_git_repo_config.source_paths.values_filename}",
									]
								}
								repoURL=local.liferay_helm_chart_config.source_repo_url_value
								targetRevision=local.liferay_helm_chart_config.version
							},
							local.liferay_helm_chart_config.path != null ? { path=local.liferay_helm_chart_config.path } : { chart=local.liferay_helm_chart_config.source_chart_value }
						),
						{
							ref="values"
							repoURL=var.liferay_git_repo_url
							targetRevision=var.liferay_git_repo_config.revision
						},
					]
					ignoreDifferences =[
						{
							group=""
							jsonPointers =["/data"]
							kind="Secret"
							name="liferay-default"
						},
					]
					syncPolicy={
						automated={
							prune=true
							selfHeal=true
						}
						syncOptions =[
							"CreateNamespace=true",
							"RespectIgnoreDifferences=true",
						]
					}
				}
			}
		}
	}
}
resource "kubernetes_manifest" "liferay_appproject" {
	depends_on=[kubernetes_manifest.infrastructure_appproject]
	field_manager {
		force_conflicts =true
		name=local.terraform_manager_name
	}
	manifest={
		apiVersion="argoproj.io/v1alpha1"
		kind="AppProject"
		metadata={
			annotations ={
				"argocd.argoproj.io/compare-options"="IgnoreExtraneous"
			}
			labels =merge(
				local.common_labels,
				{
					"app.kubernetes.io/name"="liferay-appproject"
			})
			name=local.liferay_appproject_name
			namespace=var.argocd_namespace
		}
		spec={
			clusterResourceWhitelist=[
				{
					group="*"
					kind="*"
				},
			]
			description="ArgoCD Project for Liferay Cloud Native applications."
			destinations =[
				{
					namespace="liferay-*"
					server="https://kubernetes.default.svc"
				},
			]
			sourceRepos =[
				"${local.liferay_helm_chart_config.source_repo_url_value}",
				"${local.liferay_helm_chart_config.source_repo_url_value}/*",
				var.liferay_git_repo_url,
			]
		}
	}
}
