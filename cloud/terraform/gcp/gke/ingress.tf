resource "helm_release" "nginx_ingress" {
  # Only deploy if mode is ingress
  count = var.networking_mode == "ingress" ? 1 : 0

  name             = "nginx-ingress-controller"
  namespace        = "nginx-ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.3"
  create_namespace = true
  upgrade_install  = false
  replace          = true
  cleanup_on_fail  = true
  timeout          = 900
  wait             = true

  depends_on = [module.gke]

  values = [
    yamlencode({
      controller = {
        config = {
          "use-forwarded-headers"      = "true"
          "compute-full-forwarded-for" = "true"
          "use-proxy-protocol"         = "false" # GCP L4 LB usually doesn't need Proxy Protocol if externalTrafficPolicy is Local
        }
        service = {
          type = "ClusterIP"
          annotations = {
            "cloud.google.com/load-balancer-type" = "Internal"
          }
        }
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
      }
    })
  ]
}