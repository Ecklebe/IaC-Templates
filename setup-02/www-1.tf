resource "docker_container" "www-1" {
  image             = docker_image.ubuntu-ssh.latest
  name              = "www-1"
  must_run          = true
  publish_all_ports = true
  command           = ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
  ports {
    internal = 22
    external = 8022
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.nginx.rule"
    value = "Host(`web.${var.domain}`)"
  }
  labels {
    label = "traefik.http.routers.nginx.entrypoints"
    value = "web"
  }
  labels {
    label = "traefik.http.services.web.loadbalancer.server.port"
    value = "80"
  }
  provisioner "remote-exec" {
    connection {
      host     = "${var.domain}"
      user     = var.docker_image_root_user
      type     = "ssh"
      password = var.docker_image_root_password
      timeout  = "1m"
      port     = "8022"
    }
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Install nginx
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install nginx"
    ]
  }
}