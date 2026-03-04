resource "kubernetes_manifest" "force_spot_nodes_policy" {
	count=var.spot ? 1 : 0
	depends_on=[helm_release.kyverno]

	manifest={
		apiVersion="kyverno.io/v1"
		kind="ClusterPolicy"
		metadata={
			name="force-spot-nodes"
			annotations ={
				"policies.kyverno.io/title"="Force Spot Nodes"
				"policies.kyverno.io/category"="Cost Optimization"
				"policies.kyverno.io/description"="Automatically injects GKE spot node affinity and tolerations to all Pods except for system namespaces."
			}
		}
		spec={
			background=false
			rules =[
				{
					name="inject-spot-affinity-and-tolerations"
					match={
						any=[
							{
								resources ={
									kinds =["Pod"]
								}
							}
						]
					}
					exclude={
						any=[
							{
								resources ={
									namespaces =[
										"kube-system",
										"kyverno",
										"gatekeeper-system",
										"gke-system",
									]
								}
							}
						]
					}
					mutate={
						patchStrategicMerge={
							spec={
								tolerations =[
									{
										effect="NoSchedule"
										key="cloud.google.com/gke-spot"
										operator="Equal"
										value="true"
									}
								]
								affinity={
									nodeAffinity={
										requiredDuringSchedulingIgnoredDuringExecution={
											nodeSelectorTerms =[
												{
													matchExpressions =[
														{
															key="cloud.google.com/gke-spot"
															operator="In"
															values =["true"]
														}
													]
												}
											]
										}
										preferredDuringSchedulingIgnoredDuringExecution=[
											{
												preference={
													matchExpressions =[
														{
															key="cloud.google.com/compute-class"
															operator="In"
															values =["Scale-Out"]
														}
													]
												}
												weight=100
											}
										]
									}
								}
							}
						}
					}
				}
			]
		}
	}
}
