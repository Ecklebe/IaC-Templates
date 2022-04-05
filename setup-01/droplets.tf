resource "docker_container" "ubuntu" {
  image             = docker_image.ubuntu-ssh.latest
  name              = data.external.droplet_name.result.name
  must_run          = true
  publish_all_ports = true
  command           = ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
  ports {
    internal = 22
    external = 8022
  }
  ports {
    internal = 80
    external = 8080
  }

  provisioner "remote-exec" {
    connection {
      host     = "localhost"
      user     = var.docker_image_root_user
      type     = "ssh"
      password = var.docker_image_root_password
      timeout  = "1m"
      port     = "8022"
    }
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Install Apache
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install apache2"
    ]
  }
}