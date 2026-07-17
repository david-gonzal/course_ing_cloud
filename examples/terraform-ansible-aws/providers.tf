terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Añadimos tls para generar la llave criptográfica
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # Añadimos local para poder descargar el archivo .pem al disco local
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}