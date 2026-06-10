# Configuración y requerimientos de proveedores
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  # En Mac/Linux se conecta por el socket UNIX local de Docker Desktop
  host = "unix:///var/run/docker.sock"
}
