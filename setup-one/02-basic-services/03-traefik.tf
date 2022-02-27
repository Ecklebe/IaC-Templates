/*
Notes:

kubectl port-forward %(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name)% 9000:9000
kubectl port-forward traefik-87fd67f5-sfnd8 9000:9000
*/
# Variable declaration

variable "traefik_namespace" {
  description = "Name of the namespace where Traefik will be located"
  type        = string
  default     = "traefik"
}

resource "kubernetes_secret" "traefik-dashboard-auth" {
  metadata {
    name      = "auth"
    namespace = var.traefik_namespace
  }
  data = {
    username = "traefik-admin"
    password = "traefik~2022"
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "traefik-dashboard-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "dashboard-middleware"
      "namespace" = var.traefik_namespace
    }
    "spec" = {
      "basicAuth" = {
        "secret" = kubernetes_secret.traefik-dashboard-auth.metadata[0].name
      }
    }
  }
}

resource "kubernetes_manifest" "traefik-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "traefik-dashboard2"
      "namespace" = var.traefik_namespace
    }
    "spec" = {
      #"entryPoints" = ["websecure"]
      "entryPoints" = ["websecure"]
      #"entryPoints" = ["traefik"]
      "tls" = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
      "routes" = [
        {
          "match" = "Host(`traefik.localhost`)"
          "kind"  = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.traefik-dashboard-middleware.manifest.metadata.name
              "namespace" = var.traefik_namespace
            }
          ]
          "services" = [
            {
              "name" = "api@internal"
              "kind" = "TraefikService"
            }
          ]
        }
      ]
    }
  }
}