variable "python3_cmd" {
  description = "Command to call python 3"
  type        = string
  default     = "python"
}

data "external" "droplet_name" {
  program = [var.python3_cmd, "${path.module}/external/name-generator.py"]
}