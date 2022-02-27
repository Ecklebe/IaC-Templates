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
            mount_path = "/run/desktop/mnt/host/c/kubernetes/registry"
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
    type = "NodePort"
  }
}