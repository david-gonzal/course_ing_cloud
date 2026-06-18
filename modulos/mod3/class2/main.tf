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

# ==========================================
# SECCIÓN DE SEGURIDAD: GENERACIÓN DE LLAVE SSH
# ==========================================

# 1. Genera un par de llaves privadas usando algoritmo RSA de 4096 bits
resource "tls_private_key" "key_generada" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Registra la llave pública generada en AWS bajo un nombre específico
resource "aws_key_pair" "key_pair_aws" {
  key_name   = "pem-lab-terraform"
  public_key = tls_private_key.key_generada.public_key_openssh
}

# 3. Descarga la llave PRIVADA en la máquina del alumno (formato .pem)
# Se aplica un "chmod 400" básico mediante la configuración del archivo
resource "local_file" "guardar_pem" {
  content         = tls_private_key.key_generada.private_key_pem
  filename        = "${path.module}/pem-lab-terraform.pem"
  file_permission = "0400" # Permiso estricto de lectura de Linux/macOS requerido por SSH
}

# ==========================================
# RECURSOS DE INFRAESTRUCTURA DE RED Y EC2
# ==========================================

# 4. Crear Security Group para permitir SSH y HTTP
resource "aws_security_group" "sg_clase" {
  name        = "sg_ansible_docker_lab"
  description = "Permitir SSH y trafico Web"

  ingress {
    description = "SSH de mi maquina"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Crear la Instancia EC2 Ubuntu vinculada a la nueva llave
resource "aws_instance" "servidor_clase" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS en us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_clase.id]
  
  # Vinculamos dinámicamente con el Key Pair que registramos arriba
  key_name               = aws_key_pair.key_pair_aws.key_name 

  tags = {
    Name = "Servidor-Lab-Integrado"
  }
}

# ==========================================
# OUTPUTS PARA OUTPUT DE LA TERMINAL
# ==========================================

output "instancia_ip_publica" {
  value       = aws_instance.servidor_clase.public_ip
  description = "La IP publica del servidor para el inventario de Ansible"
}

output "ruta_llave_privada" {
  value       = local_file.guardar_pem.filename
  description = "Ubicación local de la clave privada generada"
}