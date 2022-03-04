/*
https://faun.pub/install-a-private-docker-container-registry-in-kubernetes-7fb25820fc61
https://github.com/twuni/docker-registry.helm
https://www.nearform.com/blog/how-to-run-a-public-docker-registry-in-kubernetes/
https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes

https://github.com/SeldonIO/k8s-local-docker-registry/blob/master/docker-private-registry.json


issue with not accesing docker images
https://forums.docker.com/t/cant-access-local-images-with-docker-for-windows-in-kubernetes-linux-mode/59573

*/
resource "kubernetes_namespace" "registry" {
  metadata {
    annotations = {
      name = "registry"
    }
    name = "registry"
  }
}

resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "docker-private-registry"
    namespace = kubernetes_namespace.registry.metadata[0].name
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
    namespace = kubernetes_namespace.registry.metadata[0].name
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

resource "kubernetes_manifest" "registry-chain-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "chain-middleware"
      "namespace" = kubernetes_namespace.registry.metadata[0].name
    }
    "spec" = {
      "chain" = {
        "middlewares" = [
          {
            "name" = kubernetes_manifest.traefik-redirect-middleware.manifest.metadata.name
          }
        ]
      }
    }
  }
}


resource "kubernetes_manifest" "registry-ingress-route-secure" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "ingress-route-secure"
      "namespace" = kubernetes_namespace.registry.metadata[0].name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
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
              "port" = kubernetes_service.registry.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "registry-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "ingress-route"
      "namespace" = kubernetes_namespace.registry.metadata[0].name
    }
    "spec" = {
      "entryPoints" = ["web"]
      "routes" = [
        {
          "match" = "Host(`registry.localhost`)"
          "kind"  = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.registry-chain-middleware.manifest.metadata.name
              "namespace" = kubernetes_namespace.registry.metadata[0].name
            }
          ]
          "services" = [
            {
              "name" = kubernetes_service.registry.metadata[0].name
              "port" = kubernetes_service.registry.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}