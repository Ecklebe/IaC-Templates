resource "kubernetes_manifest" "grafana-middleware-strip-prefix" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "grafana-middleware-strip-prefix"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "stripPrefix" = {
        "prefixes" = ["/grafana"]
      }
    }
  }
}

resource "kubernetes_manifest" "grafana-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "grafana-dashboard"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure", "web"]
      "routes"      = [
        {
          "match"       = "Host(`grafana.${var.domain}`) || (Host(`${var.domain}`) && PathPrefix(`/grafana`))"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.grafana-middleware-strip-prefix.manifest.metadata.name
              "namespace" = var.metrics_namespace
            }
          ]
          "services" = [
            {
              "name" = "prometheus-grafana"
              "port" = "80"
            }
          ]
        }
      ]
    }
  }
}