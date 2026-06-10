# Definición de la infraestructura a desplegar
resource "docker_image" "nginx_image" {
  #name         = "nginx:latest"
  name         = "nginx:stable-alpine3.23-perl"
  keep_locally = false
}

resource "docker_container" "nginx_container" {
  image = docker_image.nginx_image.image_id
  name  = var.container_name

  ports {
    internal = 80
    external = var.external_port
  }
}