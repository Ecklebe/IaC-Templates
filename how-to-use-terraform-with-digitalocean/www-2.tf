resource "docker_container" "www-2" {
  image             = docker_image.ubuntu-ssh.latest
  name              = "www-2"
  must_run          = true
  publish_all_ports = true
  command           = ["/usr/bin/sudo", "/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
  ports {
    internal = 22
    external = 8122
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
      port     = "8122"
    }
    inline = [
      "export PATH=$PATH:/usr/bin",
      # Install nginx
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install nginx"
    ]
  }
}