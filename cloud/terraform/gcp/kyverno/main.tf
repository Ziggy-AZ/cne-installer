locals {
	common_labels ={
		"app.kubernetes.io/managed-by"=local.terraform_manager_name
		"environment"="internal"
	}
	terraform_manager_name="liferay-cloud-native-terraform"
}

resource "kubernetes_namespace_v1" "kyverno" {
	metadata {
		labels =local.common_labels
		name=var.kyverno_namespace
	}
}

resource "helm_release" "kyverno" {
	name="kyverno"
	repository="https://kyverno.github.io/kyverno/"
	chart="kyverno"
	namespace=kubernetes_namespace_v1.kyverno.metadata[0].name
	version="3.3.4"

	values =[
		yamlencode({
			admissionController={
				replicas =2
				container={
					resources ={
						limits ={
							memory="512Mi"
						}
						requests ={
							cpu="100m"
							memory="256Mi"
						}
					}
				}
			}
			backgroundController={
				replicas =2
				container={
					resources ={
						limits ={
							memory="512Mi"
						}
						requests ={
							cpu="100m"
							memory="256Mi"
						}
					}
				}
			}
			cleanupController={
				replicas =2
				container={
					resources ={
						limits ={
							memory="512Mi"
						}
						requests ={
							cpu="100m"
							memory="256Mi"
						}
					}
				}
			}
			reportsController={
				replicas =2
				container={
					resources ={
						limits ={
							memory="512Mi"
						}
						requests ={
							cpu="100m"
							memory="256Mi"
						}
					}
				}
			}
		})
	]
}
