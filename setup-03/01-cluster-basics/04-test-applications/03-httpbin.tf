resource "kubernetes_namespace" "httpbin" {
  metadata {
    annotations = {
      name = "httpbin"
    }
    name        = "httpbin"
  }
}

resource "kubernetes_deployment" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.httpbin.metadata[0].name
    labels    = {
      "app" = "httpbin"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "httpbin"
      }
    }
    template {
      metadata {
        labels = {
          app : "httpbin"
        }
      }
      spec {
        container {
          name              = "httpbin"
          image             = "docker.io/kennethreitz/httpbin"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpbin" {
  metadata {
    name      = kubernetes_deployment.httpbin.metadata[0].labels.app
    namespace = kubernetes_namespace.httpbin.metadata[0].name
  }
  spec {
    port {
      port        = 8000
      target_port = 80
      name        = "http"
    }
    selector = {
      app : kubernetes_deployment.httpbin.metadata[0].labels.app
    }
  }
}

resource "kubernetes_manifest" "httpbin-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = kubernetes_deployment.httpbin.metadata[0].labels.app
      "namespace" = kubernetes_namespace.httpbin.metadata[0].name
    }
    "spec"       = {
      #"entryPoints" = ["websecure"]
      "entryPoints" = ["web"]
      #"tls" =  {
      #  "secretName" = "traefik-dashboard-cert"
      #}
      "routes"      = [
        {
          "match"    = "Host(`httpbin.localhost`)"
          "kind"     = "Rule"
          "services" = [
            {
              "name" = kubernetes_service.httpbin.metadata[0].name
              "port" = kubernetes_service.httpbin.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}
