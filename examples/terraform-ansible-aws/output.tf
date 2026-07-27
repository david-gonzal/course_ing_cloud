# ==========================================
# OUTPUTS DUPLICADOS
# ==========================================

output "backend_ip" {
  value       = aws_instance.backend.public_ip
  description = "IP del servidor de Backend"
}

output "frontend_ip" {
  value       = aws_instance.frontend.public_ip
  description = "IP del servidor de Frontend"
}