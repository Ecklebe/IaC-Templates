/*
With code and ideas from:
https://getbetterdevops.io/terraform-with-helm
https://getbetterdevops.io/setup-prometheus-and-grafana-on-kubernetes/

*/

variable "metrics_namespace" {
  description = "The namespace to create and where to deploy resources."
  type        = string
}
variable "grafana_username" {
  description = "The username to use to connect to Grafana UI."
  type        = string
}

variable "grafana_password" {
  description = "The credentials to use to connect to Grafana UI."
  type        = string
}

resource "kubernetes_namespace" "metrics_namespace" {
  metadata {
    annotations = {
      name = var.metrics_namespace
    }
    name = var.metrics_namespace
  }
}

data "template_file" "kube_stack_prometheus_values" {
  template = file("./templates/monitoring-values.yml")

  vars = {
    GRAFANA_SERVICE_ACCOUNT = "grafana"
    GRAFANA_ADMIN_USER      = var.grafana_username
    GRAFANA_ADMIN_PASSWORD  = var.grafana_password
  }
}

resource "helm_release" "prometheus" {
  chart        = "kube-prometheus-stack"
  name         = "prometheus"
  namespace    = var.metrics_namespace
  repository   = "https://prometheus-community.github.io/helm-charts"
  force_update = true

  values = [
    data.template_file.kube_stack_prometheus_values.rendered
  ]
}