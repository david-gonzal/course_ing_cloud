Ejecución del Despliegue

    Desplegar Infraestructura:
    Bash

    terraform init
    terraform apply -auto-approve

    Ejecutar Ansible:
    Bash

    ansible-playbook -i hosts.ini playbook.yml

    Verificación de la Demo:

        Probar la app en Región 1:
        Bash

        curl http://<IP_EC2_PRIMARY>:30080/

        Simular DRP (Punto 2): Promover la Read Replica a Master en us-east-2 mediante la CLI de AWS y reorientar el registro en Route 53 apuntando a <IP_EC2_SECONDARY>.

        Simular Auto-Healing K8s (Punto 3): Eliminar un Pod en el servidor con kubectl delete pod y observar su recreación inmediata.