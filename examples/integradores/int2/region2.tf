# Data Source VPC por defecto us-east-2
data "aws_vpc" "vpc_r2" {
  provider = aws.us_east_2
  count    = var.enable_drp_region2 ? 1 : 0
  default  = true
}

# Key Pair para SSH (Región 2)
resource "aws_key_pair" "key_r2" {
  provider   = aws.us_east_2
  count      = var.enable_drp_region2 ? 1 : 0
  key_name   = "deployer-key-r2"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group EC2 (Región 2)
resource "aws_security_group" "ec2_sg_r2" {
  provider    = aws.us_east_2
  count       = var.enable_drp_region2 ? 1 : 0
  name        = "ec2-k3s-sg-r2"
  description = "Permitir SSH, HTTP y NodePort de K8s"
  vpc_id      = data.aws_vpc.vpc_r2[0].id

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

# Security Group RDS (Región 2)
resource "aws_security_group" "rds_sg_r2" {
  provider    = aws.us_east_2
  count       = var.enable_drp_region2 ? 1 : 0
  name        = "rds-sg-r2"
  description = "Acceso a Postgres desde EC2 k3s"
  vpc_id      = data.aws_vpc.vpc_r2[0].id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg_r2[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AMI Amazon Linux 2023 (Región 2)
data "aws_ami" "ami_r2" {
  provider    = aws.us_east_2
  count       = var.enable_drp_region2 ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 t3.micro para k3s (Región 2)
resource "aws_instance" "k3s_node_r2" {
  provider               = aws.us_east_2
  count                  = var.enable_drp_region2 ? 1 : 0
  ami                    = data.aws_ami.ami_r2[0].id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_r2[0].key_name # 👈 Clave SSH agregada
  vpc_security_group_ids = [aws_security_group.ec2_sg_r2[0].id]
  associate_public_ip_address = true # 👈 Forzar IP Pública

  tags = {
    Name = "k3s-node-us-east-2"
    Role = "Secondary"
  }
}

# RDS Cross-Region Read Replica (Región 2)
resource "aws_db_instance" "rds_replica" {
  provider               = aws.us_east_2
  count                  = var.enable_drp_region2 ? 1 : 0
  identifier             = "banco-db-replica"
  instance_class         = "db.t3.micro"
  replicate_source_db    = aws_db_instance.rds_primary.arn
  vpc_security_group_ids = [aws_security_group.rds_sg_r2[0].id]
  skip_final_snapshot     = true
  publicly_accessible     = false
}