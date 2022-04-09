variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
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