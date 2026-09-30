# Zona Privada de Route 53
resource "aws_route53_zone" "primary_zone" {
  name = var.domain_name

  # VPC de Región 1 (Siempre)
  vpc {
    vpc_id = data.aws_vpc.vpc_r1.id
  }

  # VPC de Región 2 (Dinámico / Opcional)
  dynamic "vpc" {
    for_each = var.enable_drp_region2 ? [1] : []
    content {
      vpc_id     = data.aws_vpc.vpc_r2[0].id
      vpc_region = var.aws_region_r2
    }
  }
}

# Registro A apuntando a la EC2 de Región 1
resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.primary_zone.zone_id
  name    = "app.${var.domain_name}"
  type    = "A"
  ttl     = 10
  records = [aws_instance.k3s_node_r1.public_ip]
}