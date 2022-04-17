/*
https://traefik.io/blog/capture-traefik-metrics-for-apps-on-kubernetes-with-prometheus/
https://community.traefik.io/t/capture-traefik-metrics-for-apps-on-kubernetes-with-prometheus/9811
*/

variable "traefik_namespace" {
  description = "Name of the namespace where Traefik will be located"
  type        = string
}

variable "traefik_admin_username" {
  description = "Name of the admin account"
  type        = string
}

variable "traefik_admin_password" {
  description = "Password of the admin account"
  type        = string
}

variable "domain" {
  description = "Domain to use"
  type        = string
}

resource "kubernetes_secret" "traefik-dashboard-auth" {
  metadata {
    name      = "auth"
    namespace = var.traefik_namespace
  }
  data = {
    username = var.traefik_admin_username
    password = var.traefik_admin_password
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "traefik-dashboard-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
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

resource "kubernetes_manifest" "traefik-redirect-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "redirect-middleware"
      "namespace" = var.traefik_namespace
    }
    "spec" = {
      "redirectScheme" = {
        "scheme"    = "https"
        "permanent" = "true"
      }
    }
  }
}

resource "kubernetes_manifest" "traefik-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "traefik-dashboard2"
      "namespace" = var.traefik_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "tls"         = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
      "routes" = [
        {
          "match"       = "(Host(`traefik.${var.domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))) || (Host(`${var.domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`)))"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = "auth-forwardauth-authelia@kubernetescrd"
              "namespace" = "auth"
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