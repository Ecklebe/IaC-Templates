resource "kubernetes_manifest" "alertmanager-dashboard-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "alertmanager-dashboard"
      "namespace" = var.monitoring_namespace
    }
    "spec" = {
      "entryPoints" = ["web"]
      #"tls" = {
      #  "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      #}
      "routes" = [
        {
          "match" = "Host(`alertmanager.localhost`)"
          "kind"  = "Rule"
          "services" = [
            {
              "name" = "prometheus-kube-prometheus-alertmanager"
              "port" = "9093"
            }
          ]
        }
      ]
    }
  }
}