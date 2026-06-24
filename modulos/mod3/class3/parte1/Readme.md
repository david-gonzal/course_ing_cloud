🎯 Objetivo del Laboratorio

El alumno aprenderá a instalar y verificar Docker localmente en su máquina de desarrollo, construirá sus primeras imágenes personalizadas a través de un archivo Dockerfile, y orquestará un stack de tres capas completo (Frontend, Backend y Base de Datos) de forma efímera utilizando un archivo docker-compose.yml.

🗺️ Arquitectura de la Aplicación (Fase 1: Efímera)

       [ CLIENTE (Navegador) ] ───> Puerto 8080 (Localhost)
                                        │
                                        ▼
                           +--------------------------+
                           |    CONTENEDOR FRONT     | (Construido con Dockerfile)
                           |   (Nginx estático HTML)  |
                           +--------------------------+
                                        │
                           Petición HTTP /api/data (Puerto 3000)
                                        │
                                        ▼
                           +--------------------------+
                           |    CONTENEDOR BACK      | (Construido con Dockerfile)
                           |     (Node.js API)        |
                           +--------------------------+
                                        │
                             Conexión interna (Puerto 5432)
                                        │
                                        ▼
                           +--------------------------+
                           |      CONTENEDOR DB       | (Imagen Oficial: postgres)
                           |      Postgres (EFÍMERO)  |
                           +--------------------------+



📋 Paso 0: Verificación de Docker en la terminal

Pídele a tus alumnos que inicien su terminal (PowerShell, WSL o Terminal de macOS) y corran el primer "hola mundo" de validación del servicio:

# Validar versión instalada
docker --version

# Ejecutar imagen de prueba oficial de Docker
docker run --rm hello-world

docker compose up -d