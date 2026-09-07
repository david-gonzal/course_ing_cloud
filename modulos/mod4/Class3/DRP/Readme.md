# Guía de Ejecución

## Despliegue y Operación Normal

    docker-compose up -d

## Terminal 1, inicia la generación continua de tráfico HTTP

    while true; do curl -X POST http://localhost:8080/tx; sleep 1; done

## Terminal 2, muestra la replicación activa demostrando el RPO cercano a 0

    docker exec -it db-replica psql -U admin -d appdb -c "SELECT * FROM transacciones ORDER BY id DESC LIMIT 3;"

# Inyección del Desastre (Chaos Event)

    Simula la caída total del sitio primario

    # En la Terminal 1, el tráfico devolverá errores 500 o fallos de conexión

# Medición de RPO y Ejecución del DRP

## Calcular RPO (Pérdida de datos):

    docker exec -it db-replica psql -U admin -d appdb -c "SELECT id, created_at FROM transacciones ORDER BY id DESC LIMIT 1;"
    
## Ejecutar Failover (Warm Standby / Promoción):

    docker exec -it db-replica pg_ctl promote -D /var/lib/postgresql/data

# Calcular RTO (Tiempo de Recuperación):
    Observa la Terminal 1. En cuanto veas que la terminal vuelve a mostrar respuestas exitosas (Node B -> TX X OK), detén el cronómetro. Ese tiempo transcurrido es tu RTO real de la demo.

# Limpieza para Repetir el Simulacro

    docker-compose down -v