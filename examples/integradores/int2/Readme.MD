Ejecución del Despliegue

    Desplegar Infraestructura:
    Bash

    terraform init
    terraform apply -auto-approve

    terraform output

    Ejecutar Ansible:
    Bash

    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i host.ini playbook.yml

    Verificación de la Demo:

        Probar la app en Región 1:
        Bash

        curl http://<IP_EC2_PRIMARY>:30080/

        Simular DRP (Punto 2): Promover la Read Replica a Master en us-east-2 mediante la CLI de AWS y reorientar el registro en Route 53 apuntando a <IP_EC2_SECONDARY>.

        Simular Auto-Healing K8s (Punto 3): Eliminar un Pod en el servidor con kubectl delete pod y observar su recreación inmediata.


Pruebas:
# 1. Comprobar salud (conectividad EC2 -> RDS Primario)
curl http://13.221.155.108:30080/

curl http://3.15.225.119:30080/

# Respuesta esperada:
# {"region":"k3s-primary","status":"healthy"}

# 2. Registrar transacciones/ventas (Prueba de Escritura)
curl -X POST http://13.221.155.108:30080/venta \
  -H "Content-Type: application/json" \
  -d '{"monto": 1500.50}'

curl -X POST http://3.15.225.119:30080/venta \
  -H "Content-Type: application/json" \
  -d '{"monto": 800.00}'

# Respuesta esperada:
# {"id":1,"monto":1500.5,"status":"success"}
# {"id":2,"monto":800.0,"status":"success"}



aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=k3s-node-us-east-1" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text


PGPASSWORD='Secret123!' psql "host=127.0.0.1 port=5433 user=admin_banco dbname=banco_db sslmode=require"

ssh -i ~/.ssh/id_rsa -L 5433:banco-db-replica.cnmogkm8gdpd.us-east-2.rds.amazonaws.com:5432 ec2-user@3.15.225.119 -N &

