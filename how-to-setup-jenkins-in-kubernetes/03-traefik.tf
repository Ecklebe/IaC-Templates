/*
https://github.com/rafrasenberg/kubernetes-terraform-traefik-cert-manager
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


# Create Traefik namespace
resource "kubernetes_namespace" "traefik" {
  metadata {
    annotations = {
      name = "traefik"
    }
    name = "traefik"
  }
}

# Deploy Ingress Controller Traefik
resource "helm_release" "traefik_helm_release" {
  name       = var.ingress_gateway_chart_name
  repository = var.ingress_gateway_chart_repo
  chart      = var.ingress_gateway_chart_name
  version    = var.ingress_gateway_chart_version
  namespace  = kubernetes_namespace.traefik.metadata.0.name

  values = [
    file("templates/traefik-values.yml")
  ]
}


/*
resource "kubernetes_secret" "traefik-dashboard-auth" {
  metadata {
    name = "traefik-dashboard-auth"
    namespace = kubernetes_namespace.ingress_gateway_namespace.metadata.0.name
  }
  data = {
    users: "cmFmOiRhcHIxJGRiN1VMZzFGJDB6OUFtWUVLaWRTQ0h4RkpxODdGYTEKCg=="
  }
}
*/

/*
resource "kubernetes_manifest" "traefik-dashboard-basicauth" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "traefik-dashboard-basicauth"
      "namespace" = kubernetes_namespace.ingress_gateway_namespace.metadata.0.name
    }
    "spec" = {
      "basicAuth" = {
        "secret" = "traefik-dashboard-auth"
      }
    }
  }
}
*/

/*
resource "kubernetes_manifest" "traefik-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "traefik-dashboard"
      "namespace" = kubernetes_namespace.traefik.metadata.0.name
    }
    "spec" = {
      #"entryPoints" = ["websecure"]
      "entryPoints" = ["traefik"]
      #"tls" =  {
      #  "secretName" = "traefik-dashboard-cert"
      #}
      "routes" = [
        {
        "match" = "PathPrefix(`/dashboard`) || PathPrefix(`/api`)"
        "kind" = "Rule"
        #"middlewares" = [
        #  {
        #    "name" = " traefik-dashboard-basicauth"
        #    "namespace" = kubernetes_namespace.ingress_gateway_namespace.metadata.0.name
        #  }
        #]
        "services" = [
          {
            "name" = "api@internal"
            "kind" = "TraefikService"
            "port" = "80"
          }
        ]
        }
      ]
    }
  }
}

*/