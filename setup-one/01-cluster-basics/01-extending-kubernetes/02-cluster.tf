variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
}

variable "operator_namespace" {
  description = "The namespace to create and where to deploy kubernetes operators"
  type        = string
}

resource "kubernetes_namespace" "operator" {
  metadata {
    annotations = {
      name = var.operator_namespace
    }
    name = var.operator_namespace
  }
}

# Load and connect to Kubernetes
provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

# Load and connect to Helm
provider "helm" {
  kubernetes {
    config_path = var.kubernetes_config_path
  }
}
