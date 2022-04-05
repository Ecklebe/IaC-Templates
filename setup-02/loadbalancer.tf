data "template_file" "traefik_config" {
  template = "${file("templates/traefikv2.tpl")}"

  vars = {
    docker_deamon_exposed = "${var.docker_deamon_exposed}"
  }
}

resource "docker_container" "traefik" {

  image    = "${docker_image.traefik.latest}"
  name     = "traefik_proxy"
  must_run = true
  restart  = "always"

  ports {
    internal = 80
    external = 80
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }
  ports {
    internal = 8080
    external = 9000
    protocol = "tcp"
  }
  upload {
    content = "${join(",", data.template_file.traefik_config.*.rendered)}"
    file    = "/etc/traefik/traefik.toml"
  }

  volumes {
    host_path      = "/srv/traefik"
    container_path = "/srv/"
    read_only      = false
  }
}