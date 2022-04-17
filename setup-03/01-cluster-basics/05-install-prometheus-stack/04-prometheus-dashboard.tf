resource "kubernetes_manifest" "prometheus-middleware-strip-prefix" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "prometheus-middleware-strip-prefix"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "stripPrefix" = {
        "prefixes" = ["/prometheus"]
      }
    }
  }
}

resource "kubernetes_manifest" "prometheus-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "prometheus-dashboard"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure", "web"]
      "routes"      = [
        {
          "match"       = "Host(`prometheus.${var.domain}`) || (Host(`${var.domain}`) && PathPrefix(`/prometheus`))"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.prometheus-middleware-strip-prefix.manifest.metadata.name
              "namespace" = var.metrics_namespace
            }
          ]
          "services" = [
            {
              "name" = "prometheus-kube-prometheus-prometheus"
              "port" = "9090"
            }
          ]
        }
      ]
    }
  }
}