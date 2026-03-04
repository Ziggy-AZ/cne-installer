resource "helm_release" "crossplane" {
	atomic=true
	chart="crossplane"
	cleanup_on_fail=true
	create_namespace=true
	name="crossplane"
	namespace=var.crossplane_namespace
	repository="https://charts.crossplane.io/stable"
	upgrade_install=true
	version="2.1.4"
	wait=true
	values =[
		yamlencode({
			resources ={
				limits ={
					cpu="500m"
					memory="512Mi"
				}
				requests ={
					cpu="250m"
					memory="256Mi"
				}
			}
			rbacManager={
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
			}
		})
	]
}