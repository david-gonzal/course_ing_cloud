# Rehost
Crear archivo index.html

Ejecutar:
python3 -m http.server 8000

Abrir navegador 
localhost:8000 o curl localhost:8000

Correr stack de cloudformation

validar con ip publica port 80

# Replatform

Crear archivo dockerfile
    # 1. Construir la imagen (el paquete)
    docker build -t hola-mundo-formatec .

    # 2. Ejecutar el contenedor
    # Mapeamos el puerto 8080 de tu PC al 80 del contenedor
    docker run -d -p 8080:80 hola-mundo-formatec

Ejecutamos
    # 1. Construir la imagen (el paquete)
    docker build -t hola-mundo-formatec .

    # 2. Ejecutar el contenedor
    # Mapeamos el puerto 8080 de tu PC al 80 del contenedor
    docker run -d -p 8080:80 hola-mundo-formatec

    localhost:8080

validar con ip publica port 8080
