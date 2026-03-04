resource "helm_release" "gateway_crds" {
  name             = "gateway-crds"
  chart            = "${path.module}/helm/gateway-crds"
  namespace        = "infra"
  create_namespace = true
  version          = "1.0.0"
}

resource "helm_release" "gateway_infra" {
  name             = "gateway-infra"
  chart            = "${path.module}/helm/gateway-infra"
  namespace        = "infra"
  create_namespace = true
  version          = "1.0.2"
  skip_crds        = true

  depends_on = [helm_release.gateway_crds]

  # Ensure the subchart (Envoy Controller) is enabled
  set = [{
    name  = "envoy-gateway.enabled"
    value = var.networking_mode == "gateway" ? "true" : "false"
  }]

  # Pass the domains list as a native Helm list
  values = [
    yamlencode({
      domains = var.domains
    })
  ]

  description = "Hash: ${filesha256("${path.module}/helm/gateway-infra/values.yaml")}"

  # Combine with this to ensure pods actually restart
  recreate_pods = true
}
