resource "helm_release" "jaeger_operator" {
  chart        = "jaeger-operator"
  name         = "jaegertracing"
  namespace    = var.operator_namespace
  repository   = "https://jaegertracing.github.io/helm-charts"
  force_update = true
}