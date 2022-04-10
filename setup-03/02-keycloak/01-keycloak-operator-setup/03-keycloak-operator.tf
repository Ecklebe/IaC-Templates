resource "kubernetes_manifest" "keycloak-operatorgroup" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind"       = "OperatorGroup"
    "metadata" = {
      "name"      = "operatorgroup"
      "namespace" = "default"
    }
    "spec" = {
      "targetNamespaces" = ["default"]
    }
  }
}

resource "kubernetes_manifest" "keycloak-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata" = {
      "name"      = "keycloak-operator"
      "namespace" = "default"
    }
    "spec" = {
      "channel"         = "alpha"
      "name"            = "keycloak-operator"
      "source"          = "operatorhubio-catalog"
      "sourceNamespace" = "olm"
    }
  }
}