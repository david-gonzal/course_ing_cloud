Ejecución del Despliegue

    Desplegar Infraestructura:
    Bash

    terraform init
    terraform apply -auto-approve

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
curl http://44.201.18.125:30080/

# Respuesta esperada:
# {"region":"k3s-primary","status":"healthy"}

# 2. Registrar transacciones/ventas (Prueba de Escritura)
curl -X POST http://35.172.190.122:30080/venta \
  -H "Content-Type: application/json" \
  -d '{"monto": 1500.50}'

curl -X POST http://44.201.18.125:30080/venta \
  -H "Content-Type: application/json" \
  -d '{"monto": 800.00}'

# Respuesta esperada:
# {"id":1,"monto":1500.5,"status":"success"}
# {"id":2,"monto":800.0,"status":"success"}