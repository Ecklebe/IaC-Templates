variable "olm_version" {
  type        = string
  description = "The version of olm that will be installed"
}

resource "null_resource" "operator_lifecycle_manager" {
  triggers = {
    OLM_VERSION = var.olm_version
  }

  provisioner "local-exec" {
    command = "wsl ${path.module}/scripts/deploy.sh ${self.triggers.OLM_VERSION}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "wsl ${path.module}/scripts/destroy.sh ${self.triggers.OLM_VERSION}"
  }
}