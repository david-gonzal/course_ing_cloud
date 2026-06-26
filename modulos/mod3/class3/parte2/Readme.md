Módulo 3 - Clase 2: Parte 2

🎯 Objetivo del Laboratorio

El alumno tomará la arquitectura web del Laboratorio anterior y la optimizará bajo estándares profesionales de producción:

Aislamiento de Redes (Networking): Separará la comunicación en dos redes independientes de forma que la Base de Datos sea totalmente invisible para el Frontend o el exterior, reduciendo el área de ataque.

Persistencia (Volúmenes): Integrará volúmenes locales gestionados por Docker para asegurar que los datos de Postgres sobrevivan a la destrucción del contenedor.

Optimización extrema (Multi-stage Build): Reestructurará los Dockerfiles utilizando compilación de múltiples etapas, reduciendo drásticamente el peso de las imágenes finales de producción.

🗺️ Arquitectura de Red Aislada (Fase 2: Producción)

        [ USUARIO (Navegador) ] ───> Puerto 8080 (Localhost)
                                         │
       =================== RED: red-publica (Solo Front y Back) ===================
                                         │
                                         ▼
                            +--------------------------+
                            |    CONTENEDOR FRONT     | (Multi-Stage Nginx)
                            |   (Servidor de Estáticos) |
                            +--------------------------+
                                         │
                                         ▼
                            +--------------------------+
                            |    CONTENEDOR BACK       | (Multi-Stage Node)
                            |      (API REST)          |
                            +--------------------------+
                                         │
       =================== RED: red-privada (Solo Back y DB) =====================
                                         │
                                         ▼
                            +--------------------------+
                            |      CONTENEDOR DB       | (Postgres)
                            |   Volumen: datos_postgres| <--- [ PERSISTENCIA ]
                            +--------------------------+
