resource "docker_image" "ubuntu" {
  name         = "ubuntu:20.04"
  keep_locally = true
}

resource "docker_image" "ubuntu-ssh" {
  name = "ubuntu-ssh"
  build {
    path      = "./docker/base-images/ubuntu"
    tag       = ["ubuntu-ssh:latest"]
    build_arg = {
      parent_image : docker_image.ubuntu.latest
      user : var.docker_image_root_user
      password : var.docker_image_root_password
    }
  }

}