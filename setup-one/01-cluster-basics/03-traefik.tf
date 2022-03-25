/*
https://github.com/rafrasenberg/kubernetes-terraform-traefik-cert-manager
*/
/*
Notes:

kubectl port-forward %(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name)% 9000:9000
kubectl port-forward traefik-87fd67f5-sfnd8 9000:9000
*/
# Variable declaration
variable "ingress_gateway_chart_name" {
  type        = string
  description = "Ingress Gateway Helm chart name."
}
variable "ingress_gateway_chart_repo" {
  type        = string
  description = "Ingress Gateway Helm repository name."
}
variable "ingress_gateway_chart_version" {
  type        = string
  description = "Ingress Gateway Helm repository version."
}
variable "domain" {
  description = "Path to the kubernetes config"
  type        = string
}
variable "traefik_namespace" {
  description = "Name of the namespace where Traefik will be located"
  type        = string
}

# Deploy Ingress Controller Traefik
resource "helm_release" "traefik_helm_release" {
  name         = var.ingress_gateway_chart_name
  repository   = var.ingress_gateway_chart_repo
  chart        = var.ingress_gateway_chart_name
  version      = var.ingress_gateway_chart_version
  namespace    = var.traefik_namespace
  force_update = true
  values = [
    file("templates/traefik-values.yml")
  ]
}

resource "kubernetes_service" "traefik-dashboard" {
  metadata {
    name      = "traefik-dashboard"
    namespace = var.traefik_namespace
    labels = {
      "service" = "traefik-dashboard"
    }
  }
  spec {
    port {
      port     = 9000
      protocol = "TCP"
    }
    selector = {
      app : "traefik"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "traefik-metrics" {
  metadata {
    name      = "traefik-metrics"
    namespace = var.traefik_namespace
    labels = {
      "service" = "traefik-metrics"
    }
  }
  spec {
    port {
      port     = 9100
      protocol = "TCP"
    }
    selector = {
      app : "traefik"
    }
    type = "ClusterIP"
  }
}