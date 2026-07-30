# 1. Crear Namespace dedicado para el laboratorio
resource "kubernetes_namespace" "audit_namespace" {
  metadata {
    name = "audit-lab"
  }
}

# 2. Desplegar un contenedor objetivo
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "web-app"
    namespace = kubernetes_namespace.audit_namespace.metadata[0].name
    labels = {
      env = "production"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "web-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "web-app"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}