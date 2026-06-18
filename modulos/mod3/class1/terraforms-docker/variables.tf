# Declaración de variables configurables
variable "container_name" {
  description = "Nombre asignado al contenedor de Nginx"
  type        = string
  default     = "ServidorWeb-FormaTEC"
}

variable "external_port" {
  description = "Puerto de tu máquina local expuesto al exterior"
  type        = number
  default     = 8081
}