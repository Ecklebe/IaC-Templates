terraform {
  required_providers {
    docker   = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = ">= 2.16.0"
    }
    template = {
      source  = "registry.terraform.io/hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}