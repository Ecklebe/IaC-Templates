terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = ">= 2.16.0"
    }
  }
}