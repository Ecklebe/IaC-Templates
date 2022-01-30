resource "docker_container" "whoami" {

  image    = "${docker_image.whoami.latest}"
  name     = "whoami"
  must_run = true
  restart  = "always"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.whoami.rule"
    value = "Host(`whoami.${var.domain}`)"
  }
  labels {
    label = "traefik.http.routers.whoami.entrypoints"
    value = "web"
  }
  ports {
    internal = 8000
    external = 8000
    protocol = "tcp"
  }
}