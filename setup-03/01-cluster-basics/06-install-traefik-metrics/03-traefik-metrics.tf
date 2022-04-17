/*
https://traefik.io/blog/capture-traefik-metrics-for-apps-on-kubernetes-with-prometheus/
https://community.traefik.io/t/capture-traefik-metrics-for-apps-on-kubernetes-with-prometheus/9811
*/

variable "monitoring_namespace" {
  type = string
}

variable "traefik_namespace" {
  description = "Name of the namespace where Traefik will be located"
  type        = string
}

resource "kubernetes_manifest" "traefik-metrics-service-monitor" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata"   = {
      "name"      = "traefik-metrics-service-monitor"
      "namespace" = var.monitoring_namespace
      "labels"    = {
        "app"     = "traefik"
        "release" = "prometheus"
      }
    }
    "spec"       = {
      "jobLabel"          = "traefik-metrics"
      "selector"          = {
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
      "endpoints"         = [
        {
          "port" = "metrics"
          "path" = "/metrics"
          #          "metricRelabelings" = [
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
          #              "action" = "keep"
          #              "regex" = "true"
          #            },
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
          #              "action" = "replace"
          #              "regex" = "(.+)"
          #              "targetLabel" = "__metrics_path__"
          #            },
          #            {
          #              "sourceLabels" = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
          #              "action" = "replace"
          #              "regex" = "([^:]+)(?::\\d+)?;(\\d+)"
          #              "targetLabel" = "__address__"
          #              "replacement" = "$1:$2"
          #            },
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_service_annotation_prometheus_io_scheme"]
          #              "action" = "replace"
          #              "regex" = "(https?)"
          #              "targetLabel" = "__scheme__"
          #            },
          #            {
          #              "action" = "labelmap"
          #              "regex" = "__meta_kubernetes_pod_label_(.+)"
          #            },
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_namespace"]
          #              "action" = "replace"
          #              "targetLabel" = "namespace"
          #            },
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_service_name"]
          #              "action" = "replace"
          #              "targetLabel" = "service"
          #            },
          #            {
          #              "sourceLabels" = ["__meta_kubernetes_pod_container_name"]
          #              "action" = "replace"
          #              "targetLabel" = "container"
          #            }
          #          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "traefik-prometheus-rule" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"
    "metadata"   = {
      "annotations" = {
        "meta.helm.sh/release-name"      = "prometheus"
        "meta.helm.sh/release-namespace" = var.monitoring_namespace
      }
      "labels"      = {
        "app"     = "kube-prometheus-stack-prometheus"
        "release" = "prometheus"
      }
      "name"        = "traefik-alert-rules"
      "namespace"   = var.monitoring_namespace
    }
    "spec"       = {
      "groups" = [
        {
          "name"  = "Traefik"
          "rules" = [
            {
              "alert"  = "TooManyRequest"
              "expr"   = "avg(traefik_entrypoint_open_connections{job='traefik-metrics',namespace='kube-system'}) > 5"
              "for"    = "1m"
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