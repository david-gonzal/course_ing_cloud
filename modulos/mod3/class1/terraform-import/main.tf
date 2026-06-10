#terraform import aws_instance.servidor_importadoimport {
#  to = aws_instance.servidor_importado
#  id = "i-0742a14b2f45915d2" # Reemplazar con el ID de la instancia de AWS real
#}

resource "aws_instance" "servidor_importado" {
  # Terraform completará estos atributos basándose en el estado de AWS
  ami = "ami-03120525e2a3df46f"
  instance_type = "t3.micro"
}