terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "registry.terraform.io/hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}