💻 Automatización Opción A: AWS CloudFormation (IaC Nativa)

Esta plantilla de CloudFormation (s3-sns-sqs-lambda.yaml) despliega el flujo completo de forma 100% automatizada e incluye las políticas de permisos necesarias para la interconexión segura.

    Ejecutar comando: aws cloudformation create-stack....

    Subir archivos .csv al bucket

    Ejecutar comando: aws cloudformation delete-stack

📦 Automatización Opción B: Terraform (IaC Agnóstica)

Esta es la configuración de Terraform (main.tf) equivalente para el mismo aprovisionamiento. Permite explicarles a los alumnos la diferencia entre el enfoque declarativo puro de CloudFormation (JSON/YAML) frente al lenguaje HCL estructurado y modular de HashiCorp.

correr estos comandos:
    terraform init

    terraform plan

    terraform apply

    Subir archivos .csv al bucket

    terraform destroy