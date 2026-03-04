output "argocd_ui_tools_helm_values" {
	value=yamlencode({
		configs ={
			cm={
				"resource.customizations.actions.argoproj.io_Application"=<<-EOT
					discovery.lua: |
						actions ={}
						actions["wipe-infrastructure"]={["disabled"]=false}
						actions["restore-infrastructure"]={["disabled"]=false}
						return actions
					definitions:
					- name: wipe-infrastructure
						action.lua: |
							if obj.spec.syncPolicy == nil then obj.spec.syncPolicy={} end
							if obj.spec.syncPolicy.automated == nil then obj.spec.syncPolicy.automated={} end
							if obj.spec.syncPolicy.syncOptions == nil then obj.spec.syncPolicy.syncOptions ={} end
							local hasAllowEmpty=false
							for i, v in ipairs(obj.spec.syncPolicy.syncOptions) do
								if v == "AllowEmpty=true" then hasAllowEmpty=true end
							end
							if not hasAllowEmpty then
								table.insert(obj.spec.syncPolicy.syncOptions, "AllowEmpty=true")
							end
							obj.spec.resourceSelector={ matchLabels ={ ["refresh-state"]="wiping" } }
							return obj
					- name: restore-infrastructure
						action.lua: |
							obj.spec.resourceSelector=nil
							if obj.spec.syncPolicy ~=nil and obj.spec.syncPolicy.syncOptions ~=nil then
								local newOptions ={}
								for i, v in ipairs(obj.spec.syncPolicy.syncOptions) do
									if v ~="AllowEmpty=true" then table.insert(newOptions, v) end
								end
								obj.spec.syncPolicy.syncOptions =newOptions
							end
							return obj
				EOT
			}
		}
	})
}
