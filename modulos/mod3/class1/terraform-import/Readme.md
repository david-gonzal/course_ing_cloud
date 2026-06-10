Importar Infraestructura Existente a Terraform

Uno de los mayores desafíos en el mundo laboral de DevOps es la "adopción de recursos huérfanos". A menudo, te encontrarás con infraestructuras creadas de forma manual con clics en la consola de AWS o generadas previamente mediante stacks de CloudFormation, y necesitarás migrar su gestión a Terraform sin destruirlas.

Para lograr esto, usaremos el proceso de Importación.

El Escenario

Imagina que queremos simular esta adopción en clase de manera interactiva. Para ello, primero crearemos manualmente una instancia EC2 de tipo "huérfana" mediante el uso de la AWS CLI (lo mínimo indispensable para tener un recurso real con su correspondiente ID), y posteriormente utilizaremos Terraform para adoptarla y controlarla.

Paso 0: Crear la Instancia de Origen con la AWS CLI

Pídele a tus alumnos que ejecuten este comando minimalista en su consola para simular la creación de la infraestructura externa que adoptaremos. El comando utiliza la AMI de Amazon Linux 2023 en us-east-1 (región recomendada) y le añade una etiqueta identificadora:

aws ec2 run-instances \
  --image-id ami-03120525e2a3df46f \
  --count 1 \
  --instance-type t3.micro \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ServidorAAdoptar}]' \
  --query "Instances[0].InstanceId" \
  --output text


Toma nota del ID de la instancia de AWS devuelto en la consola (ej. i-0123456789abcdef0). Lo utilizaremos en los siguientes métodos.

Método 1: El nuevo bloque import (Recomendado - Terraform 1.5+)

Este es el enfoque moderno e inmensamente didáctico para enseñar en clase, porque permite escribir la declaración del recurso y la importación de manera declarativa.

Añade este bloque al final de tu archivo main.tf en la carpeta aws-infra:

# Declaración de importación formal
import {
  to = aws_instance.servidor_importado
  id = "i-0123456789abcdef0" # Reemplazar con el ID de la instancia de AWS real
}

# Declarar el recurso vacío en main.tf para que guarde las propiedades importadas
resource "aws_instance" "servidor_importado" {
  # Terraform completará estos atributos basándose en el estado de AWS
}


Ejecuta la generación automática de código para completar tu recurso:

terraform plan -generate-config-out=generado.tf


Esto generará automáticamente un archivo generado.tf con todos los parámetros exactos (AMI, red, tipo) que tiene la instancia actualmente en AWS. ¡Los alumnos quedarán asombrados!

Aplica los cambios para sincronizar el estado:

terraform apply -auto-approve


¡Listo! Ahora la máquina manual está bajo el control total del ciclo de vida de Terraform.

Método 2: El comando clásico terraform import (CLI tradicional)

Este es el método heredado ampliamente utilizado en entornos de producción.

Primero, debes declarar manualmente el bloque de recurso vacío en tu main.tf:

resource "aws_instance" "servidor_importado" {
  # Dejar este bloque vacío por el momento
}


Ejecuta el comando de importación directa desde la terminal mapeando el ID lógico del código con el ID físico de AWS:

terraform import aws_instance.servidor_importado i-0123456789abcdef0


Verás en tu consola un mensaje de éxito: Import successful!. Si revisas tu archivo local terraform.tfstate, verás que el JSON ahora contiene toda la metadata del servidor importado.

Ejecuta terraform plan. Notarás que Terraform te avisará de inconsistencias. Debes copiar los atributos reportados en el plan hacia tu recurso aws_instance.servidor_importado en el archivo main.tf hasta que al correr terraform plan el resultado sea: "No changes. Infrastructure is up-to-date."

## Eliminado
aws ec2 terminate-instances --instance-ids i-0742a14b2f45915d2

terraform state rm aws_instance.servidor_importado