provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# 1. Instancia de Desarrollo
resource "aws_instance" "ec2_desarrollo" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro" # Capa gratuita

  # --- PASO DEMO: Comentar este bloque en el primer intento ---
  tags = {
    Proyecto         = "AppMovil"
    Entorno          = "Desarrollo"
    Owner            = "j.perez@empresa.com"
    CentroDeCostos   = "IT-500"
    HorarioOperativo = "Lunes-Viernes"
  }
  # ------------------------------------------------------------
}

# 2. Instancia de Producción
resource "aws_instance" "ec2_produccion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro" # Capa gratuita

  # --- PASO DEMO: Comentar este bloque en el primer intento ---
  tags = {
    Proyecto         = "AppMovil"
    Entorno          = "Produccion"
    Owner            = "admin@empresa.com"
    CentroDeCostos   = "MKT-102"
    HorarioOperativo = "24x7"
  }
  # ------------------------------------------------------------
}