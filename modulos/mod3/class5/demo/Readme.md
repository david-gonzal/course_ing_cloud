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
minikube addons enable metrics-server
2- Carga de imágenes:
minikube image load courseipap/backend:1.0.0
minikube image load courseipap/frontend:1.0.0
3- Despliegue de Infra:
       k apply -f labipap
4- Tunelización:
minikube tunnel (en una terminal separada)
5- Verificación:
curl -v http://localhost
curl -v http://localhost/api/data
curl -X POST http://localhost/api/data -H "Content-Type: application/json" -d '{"nombre": "Estudiante", "clase": "Kubernetes"}'
6- Resiliencia:
kubectl delete pod -l app=db
kubectl get pods -w
7- HPA 
       En deployment
              Definir limites:
              resources:
              limits:
              cpu: "100m"
              requests:
              cpu: "50m"
       Leer archivo 05-backend-hpa.yaml
       Ejecutar:
       # Bucle para estresar la CPU
       while true; do curl -s http://localhost/api/data > /dev/null; done
       kubectl get hpa -w -n lab-ipap
8- Monitoring
k apply -f monitoring
       Esperar que este todo en running
       kubectl port-forward svc/prometheus 9090:9090 -n labipap -> localhost:9090
       kubectl port-forward svc/grafana 3000:3000 -n labipap -> localhost:3000 (admin/admin)
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

Grafana:

       1. Crear la Visualización

       Haz clic en "+ Add visualization" en tu dashboard.

       Selecciona Prometheus como fuente de datos.

       En el campo de Query, escribe exactamente:
              up{job="kubernetes-pods"}
              ó
              up{instance="10.244.0.30:3000"}

       Haz clic en "Run queries".

       2. Configurar como Semáforo (Visualización "Stat")

       En el menú de la derecha ("Panel options"), busca el desplegable de visualización y selecciona "Stat".

       Ahora, en ese mismo menú de la derecha, busca la sección llamada "Thresholds" (Umbrales).

       Configura los colores de esta manera:

              Base: Cámbialo a Red (Rojo).

              Haz clic en "+ Add threshold" y establece el valor en 1. Cambia el color de ese umbral a Green (Verde).

       Esto hará que, cuando el valor sea 1 (pod saludable), el panel se vea Verde, y si el pod falla (valor 0), el panel cambie automáticamente a Rojo.

       3. Ajuste para que se vea "limpio"

       Como tienes varios pods, es posible que el panel te muestre una lista. Para que se vea como un semáforo único:

       En el panel de configuración de la derecha, busca "Stat styles" y luego "Text mode".

       Selecciona "Name" o "Value" según prefieras ver el nombre del pod o el estado.

       Si quieres ver el estado general de todos, busca la opción "Reduce options" y selecciona "Calculate: Last" y "Fields: Last".