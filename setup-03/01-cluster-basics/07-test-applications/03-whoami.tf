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
    name      = "deployment"
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
    name      = "service"
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
      "name"      = "ingress"
      "namespace" = kubernetes_namespace.whoami.metadata.0.name
      "annotations" = {
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      }
    }
    "spec" = {
      "rules" = [
        {
          "host" : "whoami.${var.domain}"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Exact"
                "backend"  = {
                  service = {
                    "name" = kubernetes_service.whoami.metadata[0].name
                    "port" = {
                      "number" = kubernetes_service.whoami.spec[0].port[0].port
                    }
                  }
                }
              },
              {
                "path"     = "/bar"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = kubernetes_service.whoami.metadata[0].name
                    "port" = {
                      "number" = kubernetes_service.whoami.spec[0].port[0].port
                    }
                  }
                }
              },
              {
                "path"     = "/foo"
                "pathType" = "Exact"
                "backend" = {
                  service = {
                    "name" = kubernetes_service.whoami.metadata[0].name
                    "port" = {
                      "number" = kubernetes_service.whoami.spec[0].port[0].port
                    }
                  }
                }
              }
            ]
          }
        },
        {
          "host" : "foo.whoami.${var.domain}"
          "http" = {
            "paths" = [
              {
                "path"     = "/"
                "pathType" = "Exact"
                "backend"  = {
                  service = {
                    "name" = kubernetes_service.whoami.metadata[0].name
                    "port" = {
                      "number" = kubernetes_service.whoami.spec[0].port[0].port
                    }
                  }
                }
              }
            ]
          }
        },
        {
          "host" : "${var.domain}"
          "http" = {
            "paths" = [
              {
                "path"     = "/whoami"
                "pathType" = "Exact"
                "backend"  = {
                  service = {
                    "name" = kubernetes_service.whoami.metadata[0].name
                    "port" = {
                      "number" = kubernetes_service.whoami.spec[0].port[0].port
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

resource "kubernetes_secret" "whoami-auth" {
  metadata {
    name      = "auth"
    namespace = kubernetes_namespace.whoami.metadata[0].name
  }
  data = {
    username = "whoami-user"
    password = "#whoami-password"
  }
  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_manifest" "whoami-middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "whoami-middleware"
      "namespace" = kubernetes_namespace.whoami.metadata[0].name
    }
    "spec" = {
      "basicAuth" = {
        "secret" = kubernetes_secret.whoami-auth.metadata[0].name
      }
    }
  }
}

resource "kubernetes_manifest" "whoami-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "ingress-route"
      "namespace" = kubernetes_namespace.whoami.metadata[0].name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes"      = [
        {
          "match"       = "Host(`${var.domain}`) && PathPrefix(`/whoami/auth`)"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = kubernetes_manifest.whoami-middleware.manifest.metadata.name
              "namespace" = kubernetes_namespace.whoami.metadata[0].name
            }
          ]
          "services" = [
            {
              "name" = kubernetes_service.whoami.metadata[0].name
              "port" = kubernetes_service.whoami.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "whoami-ingress-route-authelia" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata"   = {
      "name"      = "ingress-route-authelia"
      "namespace" = kubernetes_namespace.whoami.metadata[0].name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes"      = [
        {
          "match"       = "Host(`${var.domain}`) && PathPrefix(`/whoami/authelia`)"
          "kind"        = "Rule"
          "middlewares" = [
            {
              "name"      = "auth-forwardauth-authelia@kubernetescrd"
              "namespace" = "auth"
            }
          ]
          "services" = [
            {
              "name" = kubernetes_service.whoami.metadata[0].name
              "port" = kubernetes_service.whoami.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}