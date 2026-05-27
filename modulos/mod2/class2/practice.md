
# Paso 1: El archivo index.php (La App Dinámica)
    Para que cambie el texto según el contenedor que responda, usamos una línea simple de PHP que lee el nombre del servidor. Crea una carpeta llamada app y dentro coloca este index.php
# Paso 2: El Dockerfile de la App
    Dentro de la misma carpeta app, crea el Dockerfile para empaquetar esta mini-web
# Paso 3: El archivo nginx.conf (El Balanceador)
    Crea una carpeta llamada nginx al mismo nivel que app, y dentro coloca la configuración que le dice a Nginx que distribuya el tráfico hacia el servicio web-app de Docker
# Paso 4: El docker-compose.yml (El Orquestador)
    En la raíz de tu proyecto (fuera de las carpetas app y nginx), crea el archivo maestro
# Paso 5: El "Show" en Vivo para la Clase (La Dinámica)
    Una vez que tengas los archivos listos, ejecuta la demo ante tu alumno siguiendo estos pasos:

    Arrancar el entorno inicial:

        Bash
        docker compose up -d
    Entra a http://localhost:8080 y dale a actualizar (F5) varias veces. El alumno verá que el Contenedor ID es siempre el mismo porque solo hay un servidor corriendo.
    
    El Momento de Magia: ¡Escalar en Caliente!
    "Llegó el Black Friday, un servidor no da abasto. Vamos a aplicar Elasticidad Horizontal con un solo comando". Ejecuta en tu terminal:

        Bash
        docker compose up -d --scale web-app=3
    La Validación del Balanceo (Round Robin):
    Vuelvan al navegador en http://localhost:8080. Pídele al alumno que presione F5 repetidamente. ¡Verán cómo el ID del contenedor cambia en cada clic! Nginx está repartiendo una petición a cada contenedor de forma cíclica.

    Simular una Caída (Alta Disponibilidad / Fault Tolerance):
    Abre otra terminal y "mata" uno de los contenedores de la app a la fuerza usando docker stop <id_de_un_contenedor>. Vuelvan a actualizar el navegador: la web sigue online sin enterarse, porque Nginx detecta que ese nodo no responde y redirige el tráfico a los otros dos vivos.