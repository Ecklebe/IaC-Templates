resource "kubernetes_manifest" "jaeger-instance" {
  manifest = {
    "apiVersion" = "jaegertracing.io/v1"
    "kind"       = "Jaeger"
    "metadata" = {
      "name"      = "jaeger"
      "namespace" = var.monitoring_namespace
    }
  }
}

resource "kubernetes_manifest" "jaeger-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "jaeger-dashboard"
      "namespace" = var.monitoring_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "tls" = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
      "routes" = [
        {
          "match" = "Host(`jaeger.localhost`)"
          "kind"  = "Rule"
          "services" = [
            {
              "name" = "jaeger-query"
              "port" = "16686"
            }
          ]
        }
      ]
    }
  }
}