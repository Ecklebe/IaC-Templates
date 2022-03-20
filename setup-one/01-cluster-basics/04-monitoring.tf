/*
With code and ideas from:
https://getbetterdevops.io/terraform-with-helm
https://getbetterdevops.io/setup-prometheus-and-grafana-on-kubernetes/

*/

variable "monitoring_namespace" {
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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
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
  depends_on = [helm_release.traefik_helm_release]

  chart        = "kube-prometheus-stack"
  name         = "prometheus"
  namespace    = kubernetes_namespace.monitoring.metadata[0].name
  repository   = "https://prometheus-community.github.io/helm-charts"
  force_update = true

  values = [
    data.template_file.kube_stack_prometheus_values.rendered
  ]
}