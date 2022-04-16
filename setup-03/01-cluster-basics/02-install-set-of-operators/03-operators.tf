/*
resource "helm_release" "jaeger_operator" {
  chart        = "jaeger-operator"
  name         = "jaegertracing"
  namespace    = "operators"
  repository   = "https://jaegertracing.github.io/helm-charts"
  force_update = true
}*/

#https://olm.operatorframework.io/docs/concepts/crds/subscription/

resource "kubernetes_manifest" "jaeger-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "jaeger-operator"
      "namespace" = "operators"
    }
    "spec" = {
      "channel"         = "stable"
      "name"            = "jaeger"
      "source"          = "operatorhubio-catalog"
      "sourceNamespace" = "olm"
    }
  }
}


/*
https://github.com/zalando/postgres-operator
https://postgres-operator.readthedocs.io/en/latest/operator-ui/
*/
resource "kubernetes_manifest" "postgres-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "postgres-operator"
      "namespace" = "operators"
    }
    "spec" = {
      "channel"         = "stable"
      "name"            = "postgres-operator"
      "source"          = "operatorhubio-catalog"
      "sourceNamespace" = "olm"
    }
  }
}