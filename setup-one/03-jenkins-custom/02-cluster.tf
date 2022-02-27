/*
# Variable declaration
variable "cluster_name" {
  type        = string
  description = "Cluster name that will be created."
}
variable "cluster_region" {
  type        = string
  description = "Cluster region."
}
variable "cluster_tags" {
  type        = list(string)
  description = "Cluster tags."
}
variable "node_size" {
  type        = string
  description = "The size of the nodes in the cluster."
}
variable "node_max_count" {
  type        = number
  description = "Maximum amount of nodes in the cluster."
}
variable "node_min_count" {
  type        = number
  description = "Minimum amount of nodes in the cluster."
}


# Enable auto upgrade patch versions
data "digitalocean_kubernetes_versions" "do_cluster_version" {
  version_prefix = "1.19."
}

# Create the cluster with autoscaling on
resource "digitalocean_kubernetes_cluster" "do_cluster" {
  name         = var.cluster_name
  region       = var.cluster_region
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.do_cluster_version.latest_version
  tags         = var.cluster_tags

  node_pool {
    name       = "${var.cluster_name}-pool"
    size       = var.node_size
    min_nodes  = var.node_min_count
    max_nodes  = var.node_max_count
    auto_scale = true
  }
}
*/

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

/*
Notes:



kubectl port-forward %(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name)% 9000:9000
kubectl port-forward traefik-87fd67f5-sfnd8 9000:9000
*/

resource "kubernetes_namespace" "kubernetes-dashboard" {
  metadata {
    annotations = {
      name = "kubernetes-dashboard"
    }
    name        = "kubernetes-dashboard"
  }
}

resource "kubernetes_service_account" "kubernetes-dashboard" {
  metadata {
    name      = "admin-user"
    namespace = kubernetes_namespace.kubernetes-dashboard.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes-dashboard-crb" {
  metadata {
    name = kubernetes_service_account.kubernetes-dashboard.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubernetes-dashboard.metadata[0].name
    namespace = kubernetes_namespace.kubernetes-dashboard.metadata[0].name
  }
}

