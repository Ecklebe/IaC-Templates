variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
}

variable "domain" {
  description = "Domain to use"
  type        = string
}

# Load and connect to Kubernetes
provider "kubernetes" {
  config_path = var.kubernetes_config_path
}