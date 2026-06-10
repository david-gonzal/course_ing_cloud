# Salidas de configuración de AWS
output "ip_publica" {
  description = "IP pública para validar la web del servidor"
  value       = aws_instance.servidor_web.public_ip
}

output "instancia_arn" {
  description = "ARN identificador del recurso en AWS"
  value       = aws_instance.servidor_web.arn
}