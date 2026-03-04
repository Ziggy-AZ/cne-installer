resource "helm_release" "eck" {
  repository       = "https://helm.elastic.co"
  name             = "eck-operator"
  chart            = "eck-operator"
  version          = "3.2.0"
  namespace        = "elastic-system"
  create_namespace = true

  values = [
    yamlencode({
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    })
  ]
}
