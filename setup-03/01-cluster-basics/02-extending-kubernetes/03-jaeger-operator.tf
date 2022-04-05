/*
resource "helm_release" "jaeger_operator" {
  chart        = "jaeger-operator"
  name         = "jaegertracing"
  namespace    = "operators"
  repository   = "https://jaegertracing.github.io/helm-charts"
  force_update = true
}*/

resource "kubernetes_manifest" "jaeger-subscription" {
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind"       = "Subscription"
    "metadata"   = {
      "name"      = "jaeger-operator"
      "namespace" = "operators"
    }
    "spec"       = {
      "channel"         = "stable"
      "name"            = "jaeger"
      "source"          = "operatorhubio-catalog"
      "sourceNamespace" = "olm"
    }
  }
}