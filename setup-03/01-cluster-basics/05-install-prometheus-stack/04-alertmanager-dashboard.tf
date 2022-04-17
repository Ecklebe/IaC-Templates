resource "kubernetes_manifest" "alertmanager-middleware-strip-prefix" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "alertmanager-middleware-strip-prefix"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "stripPrefix" = {
        "prefixes" = ["/alertmanager"]
      }
    }
  }
}

resource "kubernetes_manifest" "alertmanager-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "alertmanager-dashboard"
      "namespace" = var.metrics_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure", "web"]
      "routes"      = [
        {
          "match"       = "Host(`alertmanager.${var.domain}`) || (Host(`${var.domain}`) && PathPrefix(`/alertmanager`))"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.alertmanager-middleware-strip-prefix.manifest.metadata.name
              "namespace" = var.metrics_namespace
            }
          ]
          "services" = [
            {
              "name" = "prometheus-kube-prometheus-alertmanager"
              "port" = "9093"
            }
          ]
        }
      ]
    }
  }
}