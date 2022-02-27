resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "docker-private-registry"
    namespace = "default"
    labels = {
      "app" = "docker-private-registry"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "docker-private-registry"
      }
    }
    template {
      metadata {
        labels = {
          app : "docker-private-registry"
        }
      }
      spec {
        container {
          name              = "docker-private-registry"
          image             = "registry:2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5000
            protocol       = "TCP"
          }
          volume_mount {
            mount_path = "/var/lib/registry"
            name       = "image-store"
          }
        }
        volume {
          empty_dir {}
          name = "image-store"
        }
      }
    }
  }
}

resource "kubernetes_service" "registry" {
  metadata {
    name      = "docker-private-registry"
    namespace = "default"
    labels = {
      "service" = "docker-private-registry"
    }
  }
  spec {
    port {
      port     = 5000
      protocol = "TCP"
    }
    selector = {
      app : "docker-private-registry"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "registry-ingress-route-secure" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "ingress-route-secure"
      "namespace" = "default"
    }
    "spec" = {
      "entryPoints" = ["websecure", "web"]
      "tls" = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
      "routes" = [
        {
          "match" = "Host(`registry.localhost`)"
          "kind"  = "Rule"
          "services" = [
            {
              "name" = kubernetes_service.registry.metadata[0].name
              "port" = "5000"
            }
          ]
        }
      ]
    }
  }
}