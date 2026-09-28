# Data Source VPC por defecto us-east-1
data "aws_vpc" "vpc_r1" {
  default = true
}

# Key Pair para SSH (Región 1)
resource "aws_key_pair" "key_r1" {
  key_name   = "deployer-key-r1"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group EC2 (Región 1)
resource "aws_security_group" "ec2_sg_r1" {
  name        = "ec2-k3s-sg-r1"
  description = "Permitir SSH, HTTP y NodePort de K8s"
  vpc_id      = data.aws_vpc.vpc_r1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30080
    to_port     = 30080
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

# Security Group RDS (Región 1)
resource "aws_security_group" "rds_sg_r1" {
  name        = "rds-sg-r1"
  description = "Acceso a Postgres desde EC2 k3s"
  vpc_id      = data.aws_vpc.vpc_r1.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg_r1.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AMI Amazon Linux 2023 (Región 1)
data "aws_ami" "ami_r1" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 t3.micro para k3s (Región 1)
resource "aws_instance" "k3s_node_r1" {
  ami                    = data.aws_ami.ami_r1.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_r1.key_name # 👈 Clave SSH agregada
  vpc_security_group_ids = [aws_security_group.ec2_sg_r1.id]
  associate_public_ip_address = true # 👈 Forzar IP Pública

  tags = {
    Name = "k3s-node-us-east-1"
    Role = "Primary"
  }
}

# RDS Postgres Primario (Región 1)
resource "aws_db_instance" "rds_primary" {
  identifier             = "banco-db-primary"
  allocated_storage      = 20
  max_allocated_storage  = 20
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = "banco_db"
  username               = "admin_banco"
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg_r1.id]

  # Habilita backups para poder replicar hacia Region 2
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
}