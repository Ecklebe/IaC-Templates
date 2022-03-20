resource "kubernetes_manifest" "grafana-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "grafana-dashboard"
      "namespace" = "monitoring"
    }
    "spec" = {
      "entryPoints" = ["web"]
      #"tls" = {
      #  "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      #}
      "routes" = [
        {
          "match" = "Host(`grafana.localhost`)"
          "kind"  = "Rule"
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