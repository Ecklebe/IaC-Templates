/*
Check if the service is running
(bash): kubectl port-forward -n whoami "$(kubectl get pods -n whoami| grep '^whoami-' | awk '{print $1}')" 80:80
*/
resource "kubernetes_namespace" "whoami" {
  metadata {
    annotations = {
      name = "whoami"
    }
    name = "whoami"
  }
}

resource "kubernetes_deployment" "whoami" {
  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami.metadata[0].name
    labels = {
      "app"  = "traefiklabs"
      "name" = "whoami"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        app : "traefiklabs"
        task : "whoami"
      }
    }
    template {
      metadata {
        labels = {
          app : "traefiklabs"
          task : "whoami"
        }
      }
      spec {
        container {
          name              = "whoami"
          image             = "traefik/whoami"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "whoami" {
  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami.metadata[0].name
  }
  spec {
    port {
      port = 80
      name = "http"
    }
    selector = {
      app : "traefiklabs"
      task : "whoami"
    }
  }
}

resource "kubernetes_manifest" "whoami-ingress" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "whoami"
      "namespace" = kubernetes_namespace.whoami.metadata.0.name
      "annotations" = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      }
    }
    "spec" = {
      "rules" = [
        {
          "host" : "whoami.localhost"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = "whoami"
                    "port" = {
                      "number" = "80"
                    }
                  }
                }
              },
              {
                "path"     = "/bar"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = "whoami"
                    "port" = {
                      "number" = "80"
                    }
                  }
                }
              },
              {
                "path"     = "/foo"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = "whoami"
                    "port" = {
                      "number" = "80"
                    }
                  }
                }
              }
            ]
          }
        },
        {
          "host" : "foo.whoami.localhost"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = "whoami"
                    "port" = {
                      "number" = "80"
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}
/*
resource "kubernetes_manifest" "whoami_ingress_route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "whoami"
      "namespace" = kubernetes_namespace.traefik.metadata[0].name
    }
    "spec" = {
      #"entryPoints" = ["websecure"]
      "entryPoints" = ["web"]
      #"tls" =  {
      #  "secretName" = "traefik-dashboard-cert"
      #}
      "routes" = [
        {
          "match" = "Host(`whoami.localhost`)"
          "kind" = "Rule"
          #"middlewares" = [
          #  {
          #    "name" = " traefik-dashboard-basicauth"
          #    "namespace" = kubernetes_namespace.ingress_gateway_namespace.metadata[0].name
          #  }
          #]
          "services" = [
            {
              "name" = "whoami"
              "port" = "80"
            }
          ]
        }
      ]
    }
  }
}
*/