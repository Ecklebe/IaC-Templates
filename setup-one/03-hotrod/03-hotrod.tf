resource "kubernetes_namespace" "hotrod" {
  metadata {
    annotations = {
      name = "hotrod"
    }
    name = "hotrod"
  }
}

resource "kubernetes_deployment" "hotrod" {
  metadata {
    name      = "hotrod"
    namespace = kubernetes_namespace.hotrod.metadata[0].name
    labels = {
      "app" = "hotrod"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "hotrod"
      }
    }
    template {
      metadata {
        labels = {
          app : "hotrod"
        }
      }
      spec {
        container {
          name              = "hotrod"
          image             = "docker.io/jaegertracing/example-hotrod"
          image_pull_policy = "Always"
          args              = ["all", "-j", "http://jaeger.localhost"]
          env {
            name  = "JAEGER_AGENT_HOST"
            value = "jaeger-agent.default.svc"
          }
          env {
            name  = "JAEGER_AGENT_PORT"
            value = "6831"
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hotrod" {
  metadata {
    name      = kubernetes_deployment.hotrod.metadata[0].labels.app
    namespace = kubernetes_namespace.hotrod.metadata[0].name
  }
  spec {
    port {
      port        = 8000
      target_port = 8080
      name        = "hotrod"
    }
    selector = {
      app : kubernetes_deployment.hotrod.metadata[0].labels.app
    }
  }
}

resource "kubernetes_manifest" "hotrod-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = kubernetes_deployment.hotrod.metadata[0].labels.app
      "namespace" = kubernetes_namespace.hotrod.metadata[0].name
    }
    "spec" = {
      #"entryPoints" = ["websecure"]
      "entryPoints" = ["web"]
      #"tls" =  {
      #  "secretName" = "traefik-dashboard-cert"
      #}
      "routes" = [
        {
          "match" = "Host(`hotrod.localhost`)"
          "kind"  = "Rule"
          "services" = [
            {
              "name" = kubernetes_service.hotrod.metadata[0].name
              "port" = kubernetes_service.hotrod.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}
