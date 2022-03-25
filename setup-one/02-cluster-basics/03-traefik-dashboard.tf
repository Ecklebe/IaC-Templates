/*
https://traefik.io/blog/capture-traefik-metrics-for-apps-on-kubernetes-with-prometheus/
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

resource "kubernetes_manifest" "traefik-redirect-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
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
    "metadata" = {
      "name"      = "traefik-dashboard2"
      "namespace" = var.traefik_namespace
    }
    "spec" = {
      "entryPoints" = ["websecure"]
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

resource "kubernetes_manifest" "traefik-metrics-service-monitor" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = "traefik-metrics-service-monitor"
      "namespace" = var.monitoring_namespace
      "labels" = {
        "app"     = "traefik"
        "release" = "prometheus"
      }
    }
    "spec" = {
      "jobLabel" = "traefik-metrics"
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "traefik"
          "app.kubernetes.io/name"     = "traefik-metrics"
        }
      }
      "namespaceSelector" = {
        "matchNames" = [
          var.traefik_namespace
        ]
      }
      "endpoints" = [
        {
          "port" = "metrics"
          "path" = "/metrics"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "traefik-prometheus-rule" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"
    "metadata" = {
      "annotations" = {
        "meta.helm.sh/release-name"      = "prometheus"
        "meta.helm.sh/release-namespace" = var.monitoring_namespace
      }
      "labels" = {
        "app"     = "kube-prometheus-stack-prometheus"
        "release" = "prometheus"
      }
      "name"      = "traefik-alert-rules"
      "namespace" = var.monitoring_namespace
    }
    "spec" = {
      "groups" = [
        {
          "name" = "Traefik"
          "rules" = [
            {
              "alert" = "TooManyRequest"
              "expr"  = "avg(traefik_entrypoint_open_connections{job='traefik-dashboard',namespace='kube-system'}) > 5"
              "for"   = "1m"
              "labels" = {
                "severity" = "critical"
              }
            }
          ]
        }
      ]
    }
  }
}