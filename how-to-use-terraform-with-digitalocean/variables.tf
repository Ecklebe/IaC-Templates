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

variable "traefik_version" {
  default = "v2.6"
}

variable "docker_deamon_exposed" {
  description = "The path to the docker deamon, when running on windows make sure that the deaon is exposed. Unix: unix:///var/run/docker.sock | Windows: tcp://host.docker.internal:2375"
  type        = string
  default     = "tcp://host.docker.internal:2375"
}

variable "domain" {
  default = "localhost"
}
