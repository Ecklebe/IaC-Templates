variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
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

variable "azure_subscription_id" {
  description = ""
  type        = string
}

variable "azure_subscription_tenant_id" {
  description = ""
  type        = string
}

variable "service_principal_appid" {
  description = ""
  type        = string
}

variable "service_principal_password" {
  description = ""
  type        = string
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_subscription_tenant_id
  client_id       = var.service_principal_appid
  client_secret   = var.service_principal_password
}