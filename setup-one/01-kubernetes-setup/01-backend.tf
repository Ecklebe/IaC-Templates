terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    template = {
      source  = "registry.terraform.io/hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}