data "external" "droplet_name" {
  program = [var.python3_cmd, "${path.module}/external/name-generator.py"]
}