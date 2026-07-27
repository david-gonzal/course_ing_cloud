# Laboratorio: Arquitectura Cloud con Ingress y Persistencia

Este laboratorio tiene como objetivo implementar una arquitectura de microservicios resiliente en Kubernetes, utilizando un **Ingress Controller** como puerta de enlace unificada y **volúmenes persistentes** para garantizar la integridad de los datos.

## 🎯 Objetivos del Laboratorio
Al finalizar este laboratorio, serás capaz de:
*   **Gestionar el ciclo de vida de las aplicaciones**: Desplegar servicios con contenedores propios.
*   **Dominar el enrutamiento**: Utilizar un `Ingress Controller` para exponer múltiples servicios bajo un mismo dominio mediante reglas de path (`/` vs `/api`).
*   **Validar la alta disponibilidad**: Demostrar cómo Kubernetes auto-cura servicios mediante `ReplicaSets`.
*   **Garantizar la persistencia**: Comprobar mediante `Volumes` y `Claims` que los datos de la base de datos sobreviven a la destrucción de los contenedores.

## 🗺️ Esquema de la Arquitectura
```text
                 [ CLIENTE (Navegador Local) ]
                               │
                       Puerto 80 / 443
                               ▼
                   +------------------------+
                   |    INGRESS CONTROLLER  |
                   +------------------------+
                      │                  │
               Ruta / (Front)       Ruta /api (Back)
                      │                  │
                      ▼                  ▼
               [ Serv: frontend ]  [ Serv: backend ]
                      │                  │
                      ▼                  ▼
                [ Pod: Front ]      [ Pod: Back ]
                                         │
                                         ▼ DNS: db:5432
                                   [ Serv: db ]
                                         │
                                         ▼
                                   [ Pod: DB ] ───> [ PersistentVolumeClaim ]
                                                           │
                                                           ▼
                                                    [ PersistentVolume ]

📜 Commands

0- Docker build: (front-back)
1- Minikube:
minikube start
minikube addons enable ingress
2- Carga de imágenes:
minikube image load courseipap/backend:1.0.0
minikube image load courseipap/frontend:1.0.0
3- Despliegue de Infra:
k create namespace labipap
k apply -f db-storage.yml -n labipap
k apply -f db-secrets-config.yaml -n labipap
k apply -f postgres-deployment.yaml -n labipap
4- Tunelización:
minikube tunnel (en una terminal separada)
5- Configuración Ingress:
k apply -f app-ingress.yml -n lab-ipap
6- Verificación:
curl -v http://localhost
curl -v http://localhost/api/data
curl -X POST http://localhost/api/data -H "Content-Type: application/json" -d '{"nombre": "Estudiante", "clase": "Kubernetes"}'
7- Resiliencia:
kubectl delete pod -l app=db
kubectl get pods -w
8- HPA
       Definir limites:
       resources:
          limits:
            cpu: "100m"
          requests:
            cpu: "50m"
       Ejecutar:
       kubectl autoscale deployment backend --cpu-percent=20 --min=1 --max=3 -n lab-ipap
       # Bucle para estresar la CPU
       while true; do curl -s http://localhost/api/data > /dev/null; done
       kubectl get hpa -w -n lab-ipap
9- Eliminado solucion
kubectl delete namespace lab-ipap

🧠 Knowledge
Enrutamiento Inteligente con Ingress

El Ingress actúa como un "recepcionista". En microservicios, la configuración de las rutas es crítica:

    Ruta Raíz (/): Todo el tráfico se entrega al frontend-service. Permite acceso directo a la interfaz sin reescrituras.

    Ruta API (/api): El tráfico se dirige al backend-service. Al usar pathType: Prefix sin rewrite-target global, garantizamos que el backend reciba la ruta completa que espera (/api/data).

    Lección del Error: Intentar usar un rewrite-target: / global causa errores 404, ya que "limpia" el prefijo /api y el backend termina recibiendo solo /data, perdiendo su contexto de ruta.

Alta Disponibilidad (HA) y Replicas

Al escalar a múltiples réplicas, creamos un sistema tolerante a fallos:

    Auto-curación: Si un pod falla o es eliminado, Kubernetes lanza uno nuevo para mantener el estado deseado.

    Persistencia: Gracias al uso de PersistentVolume y PersistentVolumeClaim, los datos de la base de datos residen fuera del ciclo de vida efímero de los pods. Esto asegura que, incluso si el pod de la base de datos se destruye, la información persiste intacta tras la recuperación del servicio.