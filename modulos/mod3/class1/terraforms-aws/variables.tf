# Declaración de variables (Plano estructural)
variable "aws_region" {
  description = "Región de AWS donde se levantará la infraestructura"
  type        = string
}

variable "instance_type" {
  description = "Tamaño / Tipo de instancia EC2"
  type        = string
}

variable "tag_name" {
  description = "Nombre que llevará la etiqueta Name de la EC2"
  type        = string
}