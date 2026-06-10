aws-infra/
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
└── outputs.tf


# 1. Crear y acceder a la carpeta del proyecto
mkdir aws-infra && cd aws-infra

# 2. Crear los 5 archivos descritos en el Canvas (providers.tf, variables.tf, terraform.tfvars, main.tf, outputs.tf)

# 3. Inicializar el proveedor de AWS
terraform init

# 4. Previsualizar la creación de la instancia EC2 y Security Group
terraform plan

# 5. Crear la infraestructura en AWS (instalará Apache mediante UserData automáticamente)
terraform apply -auto-approve

# 6. Probar pegando la IP pública devuelta en el output en tu navegador web

# 7. IMPORTANTE: Destruir la instancia EC2 al terminar para no generar cargos extras
terraform destroy -auto-approve