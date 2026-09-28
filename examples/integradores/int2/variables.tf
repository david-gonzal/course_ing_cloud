variable "aws_region_r1" {
  type        = string
  default     = "us-east-1"
  description = "Región Primaria"
}

variable "aws_region_r2" {
  type        = string
  default     = "us-east-2"
  description = "Región Secundaria (DRP)"
}

variable "enable_drp_region2" {
  type        = bool
  default     = false
  description = "Si es true, despliega la infraestructura DRP en la Región 2 (EC2 + Read Replica RDS)"
}

variable "domain_name" {
  type        = string
  default     = "midominio-demo-drp.com"
  description = "Nombre de dominio para la Zona Privada/Pública de Route53"
}

variable "db_password" {
  type        = string
  default     = "Secret123!"
  sensitive   = true
  description = "Contraseña de la base de datos PostgreSQL"
}