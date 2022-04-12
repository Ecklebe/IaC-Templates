/*
https://github.com/DavidIlie/kubernetes-setup
https://medium.com/@TCheronneau/sso-with-traefik-and-kubernetes-d008f9a1328a
*/

resource "kubernetes_namespace" "auth" {
  metadata {
    name = "auth"
  }
}

resource "kubernetes_secret" "authelia_secret" {
  metadata {
    name      = "auth"
    namespace = kubernetes_namespace.auth.metadata[0].name
  }
  data = {
    duo_key = "UXE1WmM4S0pldnl6eHRwQ3psTGpDbFplOXFueUVyWEZhYjE0Z01IRHN0RT0K"
  }
}

resource "helm_release" "authelia_helm_release" {
  name         = "authelia"
  repository   = "https://charts.authelia.com"
  chart        = "authelia"
  version      = "0.8.22"
  namespace    = kubernetes_namespace.auth.metadata[0].name
  force_update = true
  values = [
    file("templates/authelia-values.local.yaml")
  ]
}

/*
resource "kubernetes_manifest" "authelia-redirect-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata"   = {
      "name"      = "auth"
      "namespace" = "kube-system"
    }
    "spec"       = {
      "forwardAuth" = {
        "address"    = "http://authelia.auth.svc:8080/api/verify?rd=https://auth.localhost"
      }
    }
  }
}
*/