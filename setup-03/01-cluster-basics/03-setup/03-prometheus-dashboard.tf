resource "kubernetes_manifest" "prometheus-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "prometheus-dashboard"
      "namespace" = var.monitoring_namespace
    }
    "spec"       = {
      "entryPoints" = ["web"]
      #"tls" = {
      #  "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      #}
      "routes"      = [
        {
          "match"    = "Host(`prometheus.localhost`)"
          "kind"     = "Rule"
          "services" = [
            {
              "name" = "prometheus-kube-prometheus-prometheus"
              "port" = "9090"
            }
          ]
        }
      ]
    }
  }
}