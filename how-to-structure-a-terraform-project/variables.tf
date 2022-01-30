variable "python3_cmd" {
  description = "Command to call python 3"
  type        = string
  default     = "python"
}

variable "docker_image_root_user" {
  description = "Name of the user in the docker image. Should not be root"
  type        = string
  default     = "ubuntu"
}

variable "docker_image_root_password" {
  description = "Password of the root user in the docker image"
  type        = string
  default     = "#test-2022"
}