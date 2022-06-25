variable "kubernetes_config_path" {
  description = "Path to the kubernetes config"
  type        = string
}

#https://www.terraform.io/language/functions/pathexpand
resource "local_file" "kube_config" {
  content  = file(pathexpand("~/.kube/config"))
  filename = var.kubernetes_config_path
}