#https://www.keycloak.org/getting-started/getting-started-operator-kubernetes#_install_keycloak_operator_on_kubernetes

#https://www.keycloak.org/docs/latest/server_installation/index.html#_installing-operator

resource "kubernetes_manifest" "keycloak-instance" {
  manifest = {
    "apiVersion" = "keycloak.org/v1alpha1"
    "kind"       = "Keycloak"
    "metadata" = {
      "name"      = "mykeycloak"
      "namespace" = "default"
      "labels" = {
        "app" = "mykeycloak"
      }
    }
    "spec" = {
      "externalAccess" = {
        "enabled" = "True"
        "host"    = "keycloak.localhost"
      }
      #"extensions" = [
      #  "https://github.com/aerogear/keycloak-metrics-spi/releases/download/1.0.4/keycloak-metrics-spi-1.0.4.jar"
      #]
      #"podDisruptionBudget" = {
      #  "enabled" = "True"
      #}
      #"externalDatabase" = {
      #  "enabled" = "False"
      #}
    }
  }
}

/*
resource "kubernetes_manifest" "keycloak-basic-realm" {
  manifest = {
    "apiVersion" = "keycloak.org/v1alpha1"
    "kind"       = "KeycloakRealm"
    "metadata" = {
      "name"      = "myrealm"
      "namespace" = "default"
      "labels" = {
        "realm" = "myrealm"
      }
    }
    "spec" = {
      "realm" = {
        "realm"       = "myrealm"
        "enabled"     = "True"
        "displayName" = "Basic Realm"
      }
      "instanceSelector" = {
        "matchLabels" = {
          "app" = "mykeycloak"
        }
      }
    }
  }
}
*/

/*
resource "kubernetes_manifest" "keycloak-ingress-route" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "keycloak"
      "namespace" = "default"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "tls" = {
        "secretName" = kubernetes_secret.signed-tls-2.metadata[0].name
      }
      "routes" = [
        {
          "match" = "Host(`keycloak.localhost`)"
          "kind"  = "Rule"
          "services" = [
            {
              "name" = "keycloak"
              "port" = "8443"
            }
          ]
        }
      ]
    }
  }
}
*/