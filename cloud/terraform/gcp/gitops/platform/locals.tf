locals {
	common_labels={
		"app.kubernetes.io/managed-by"=local.terraform_manager_name
		"environment"="internal"
	}
	node_affinity=null
	node_selector={}
	terraform_manager_name="liferay-cloud-native-terraform"
	tolerations=[]
}
