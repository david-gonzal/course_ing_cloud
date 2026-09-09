#!/bin/bash
echo "Creando instancias EC2 de prueba sin etiquetas (Free Tier)..."

# 1. Obtener la AMI de Amazon Linux 2023 para x86_64
AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" \
  --output text)

echo "Usando AMI ID válida: $AMI_ID"

# 2. Especificar tipo de instancia elegible para Free Tier (t3.micro o t2.micro)
INSTANCE_TYPE="t3.micro"

# Crear EC2 de Desarrollo
INSTANCE_DEV=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --query 'Instances[0].InstanceId' \
  --output text)

# Crear EC2 de Producción
INSTANCE_PROD=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instancia Desarrollo creada: $INSTANCE_DEV (Sin Tags)"
echo "Instancia Produccion creada: $INSTANCE_PROD (Sin Tags)"