terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# Usa la configuración local de kubectl (~/.kube/config) apuntando a minikube
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}