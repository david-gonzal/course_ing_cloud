# Ej local
Steps
## 1
Iniciar Minikube
## 2
Ejecutar terraform local
## 3
Ejecutar el ansible
ansible-playbook audit-k8s.yml 
## 4
Leer el archivo generado

# AWS
## 1
activar las credenciales
## 2
Ejecutar terrafom
## 3
Ageragar el host al archivo
## 4
Ejecutar ansible
ansible-playbook -i hosts.ini deploy-and-audit.yml
## 5

