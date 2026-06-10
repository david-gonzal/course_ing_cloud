# Información útil que Terraform imprimirá en pantalla al terminar
output "url_acceso" {
  description = "URL local para ingresar a la aplicación web"
  value       = "http://localhost:${var.external_port}"
}

output "container_id" {
  description = "ID del contenedor creado en Docker"
  value       = docker_container.nginx_container.id
}