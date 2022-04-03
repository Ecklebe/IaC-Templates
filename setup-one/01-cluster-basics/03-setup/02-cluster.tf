variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
}

# Load and connect to Kubernetes
provider "kubernetes" {
  config_path = var.kubernetes_config_path
}
