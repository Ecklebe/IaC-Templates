/*
https://github.com/DavidIlie/kubernetes-setup
https://medium.com/@TCheronneau/sso-with-traefik-and-kubernetes-d008f9a1328a
*/
variable "domain" {
  description = "Domain to use"
  type        = string
}

resource "kubernetes_namespace" "auth" {
  metadata {
    name = "auth"
  }
}

resource "kubernetes_secret" "authelia_secret_users" {
  metadata {
    name      = "authelia-users"
    namespace = kubernetes_namespace.auth.metadata[0].name
    labels    = {
      "sensitive" = "true"
    }
  }
  data = {
    "users_database.yml" = file("templates/users_database.yml")
  }
}

resource "helm_release" "authelia_helm_release" {
  name         = "authelia"
  repository   = "https://charts.authelia.com"
  chart        = "authelia"
  version      = "0.8.22"
  namespace    = kubernetes_namespace.auth.metadata[0].name
  force_update = true
  values       = [
    file("templates/authelia-values.local.yaml")
  ]
  set {
    name  = "domain"
    value = var.domain
  }
}