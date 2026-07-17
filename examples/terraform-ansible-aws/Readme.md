Usuario (Navegador)
       │
       ▼ [Puerto 80]
+-----------------------------------+
|      INSTANCIA FRONTEND           |
|  (Nginx Reverse Proxy)            |
+-----------------------------------+
       │
       ▼ [Puerto 3000 o 8080 interno]
+-----------------------------------+
|      INSTANCIA BACKEND            |
|  (API / App Service)              |
+-----------------------------------+


## Aplicar Terraform


## Ejecutar esta creacion de env (es para saltar la comprobacion de SSH interactiva: "The authenticity of host... can't be established. Are you sure you want to continue connecting (yes/no)?".)
export ANSIBLE_HOST_KEY_CHECKING=False

## Esperar un minuto y validar que ambas respondan SSH antes de configurar
ansible backend:frontend -i hosts.ini -m ping

## Aplicar playbook.yaml
ansible-playbook -i hosts.ini playbook.yml