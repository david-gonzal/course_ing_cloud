# Configuración del Provider para la Región Primaria (us-east-1)
provider "aws" {
  region = var.aws_region_r1

  default_tags {
    tags = {
      Name           = "EC2-App-Hibrida"
      CentroDeCostos = "IT-500"
      Environment    = "Production"
      ManagedBy      = "Terraform"
    }
  }
}

# Configuración del Provider para la Región Secundaria / DRP (us-east-2)
provider "aws" {
  alias  = "us_east_2"
  region = var.aws_region_r2

  default_tags {
    tags = {
      Name           = "EC2-App-Hibrida-DRP"
      CentroDeCostos = "IT-500"
      Environment    = "DRP"
      ManagedBy      = "Terraform"
    }
  }
}