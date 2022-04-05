variable "monitoring_namespace" {
  description = "The namespace to create and where to deploy resources."
  type        = string
}

resource "kubernetes_manifest" "grafana-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "grafana-dashboard"
      "namespace" = var.monitoring_namespace
    }
    "spec"       = {
      "entryPoints" = ["web"]
      #"tls" = {
      #  "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      #}
      "routes"      = [
        {
          "match"    = "Host(`grafana.localhost`)"
          "kind"     = "Rule"
          "services" = [
            {
              "name" = "prometheus-grafana"
              "port" = "80"
            }
          ]
        }
      ]
    }
  }
}