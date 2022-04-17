variable "tracing_namespace" {
  type = string
}

resource "kubernetes_namespace" "tracing_namespace" {
  metadata {
    annotations = {
      name = var.tracing_namespace
    }
    name = var.tracing_namespace
  }
}

resource "kubernetes_manifest" "jaeger-instance" {
  manifest = {
    "apiVersion" = "jaegertracing.io/v1"
    "kind"       = "Jaeger"
    "metadata"   = {
      "name"      = "jaeger"
      "namespace" = var.tracing_namespace
    }
  }
}

resource "kubernetes_manifest" "jaeger-middleware-strip-prefix" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "jaeger-middleware-strip-prefix"
      "namespace" = var.tracing_namespace
    }
    "spec" = {
      "stripPrefix" = {
        "prefixes" = ["/jaeger"]
      }
    }
  }
}

resource "kubernetes_manifest" "jaeger-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "jaeger-dashboard"
      "namespace" = var.tracing_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure", "web"]
      "routes"      = [
        {
          "match"       = "Host(`jaeger.${var.domain}`) || (Host(`${var.domain}`) && PathPrefix(`/jaeger`))"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.jaeger-middleware-strip-prefix.manifest.metadata.name
              "namespace" = var.tracing_namespace
            }
          ]
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