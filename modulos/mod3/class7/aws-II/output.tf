# ==========================================
# OUTPUTS
# ==========================================
output "nginx_public_ip" {
  value       = aws_instance.servidor_nginx.public_ip
  description = "IP Pública del servidor Nginx"
}

output "apache_public_ip" {
  value       = aws_instance.servidor_apache.public_ip
  description = "IP Pública del servidor Apache"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.bucket_ingesta.id
  description = "Nombre del bucket S3 para auditorías"
}

output "ssh_private_key_pem" {
  value       = "${path.module}/pem-lab-terraform.pem"
  description = "Ruta local del archivo de clave privada PEM generado"
}