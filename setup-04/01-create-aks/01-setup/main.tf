variable "azure_resource_group_name_prefix" {
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
  type        = string
}

variable "azure_vm_size" {
  type = string
}

variable "azure_resource_group_location" {
  description = "Location of the resource group."
  type        = string
}

variable "azure_agent_count" {
}

variable "azure_ssh_public_key" {
  type = string
}

variable "azure_dns_prefix" {
  type = string
}

variable "azure_cluster_name" {
  type = string
}

# Generate random resource group name
resource "random_pet" "rg-name" {
  prefix = var.azure_resource_group_name_prefix
}

resource "azurerm_resource_group" "k8s" {
  name     = random_pet.rg-name.id
  location = var.azure_resource_group_location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.azure_cluster_name
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = var.azure_dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.azure_ssh_public_key)
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.azure_agent_count
    vm_size    = var.azure_vm_size
  }

  service_principal {
    client_id     = var.service_principal_appid
    client_secret = var.service_principal_password
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Development"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.k8s.name
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
  sensitive = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.password
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}

resource "local_file" "kube_config" {
  depends_on = [azurerm_kubernetes_cluster.k8s]
  content    = azurerm_kubernetes_cluster.k8s.kube_config_raw
  filename   = var.kubernetes_config_path
}