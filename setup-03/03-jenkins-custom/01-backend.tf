terraform {
  required_providers {
    docker     = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = ">= 2.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    template   = {
      source  = "registry.terraform.io/hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}