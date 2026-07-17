
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

# 1. Instancia para el BACKEND
resource "aws_instance" "backend" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_clase.id]
  key_name               = aws_key_pair.key_pair_aws.key_name 

  tags = { Name = "Lab-Backend" }
}

# 2. Instancia para el FRONTEND
resource "aws_instance" "frontend" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_clase.id]
  key_name               = aws_key_pair.key_pair_aws.key_name 

  tags = { Name = "Lab-Frontend" }
}

