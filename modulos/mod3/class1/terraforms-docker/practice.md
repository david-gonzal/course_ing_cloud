docker-infra/
├── providers.tf
├── variables.tf
├── main.tf
└── outputs.tf

# 1. Crear y acceder a la carpeta del proyecto
mkdir docker-infra && cd docker-infra

# 2. Crear los 4 archivos descritos en el Canvas (providers.tf, variables.tf, main.tf, outputs.tf) con sus respectivos códigos

# 3. Inicializar el proveedor de Docker local
terraform init

# 4. Ver los recursos que se van a crear
terraform plan

# 5. Desplegar el contenedor de Nginx
terraform apply -auto-approve

# 6. Probar en tu navegador ingresando a http://localhost:8081

# 7. Destruir el contenedor y limpiar tu máquina local al finalizar la clase
terraform destroy -auto-approve