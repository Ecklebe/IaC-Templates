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

#https://www.jaegertracing.io/docs/1.33/operator/
resource "kubernetes_manifest" "jaeger-instance" {
  manifest = {
    "apiVersion" = "jaegertracing.io/v1"
    "kind"       = "Jaeger"
    "metadata"   = {
      "name"      = "jaeger"
      "namespace" = var.tracing_namespace
    }
    "spec" = {
      "allInOne" = {
        "options" = {
          "query" = {
            "base-path" = "/jaeger"
          }
        }
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
          "match"    = "Host(`${var.domain}`) && PathPrefix(`/jaeger`)"
          "kind"     = "Rule"
          #"middlewares" = [
          #  {
          #    "name"      = "auth-forwardauth-authelia@kubernetescrd"
          #    "namespace" = "auth"
          #  }
          #]
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