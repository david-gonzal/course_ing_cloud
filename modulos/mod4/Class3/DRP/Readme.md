# Steps

## Levanta los contenedores en tu terminal:
    docker-compose up -d

## Terminal 1, inicia la generación continua de tráfico HTTP
    curl -X POST http://localhost:8080/tx

## Terminal 2, muestra la replicación activa
    docker exec -it db-replica psql -U admin -d appdb -c "SELECT * FROM transacciones ORDER BY id DESC LIMIT 3;"

    docker exec -it db-primary psql -U admin -d appdb -c "SELECT * FROM transacciones ORDER BY id DESC LIMIT 3;"
    

## Inyección del Desastre (Chaos Event)

    # Simula la caída total del sitio primario (error de hardware o caída de región)
    docker stop db-primary app-node-a


## Calcular RPO
    docker exec -it db-replica psql -U admin -d appdb -c "SELECT id, created_at FROM transacciones ORDER BY id DESC LIMIT 1;"

## Ejecutar Failover (Warm Standby / Promoción)
    docker exec -it db-replica su-exec postgres pg_ctl promote -D /var/lib/postgresql/data

## Terminal 1, inicia la generación continua de tráfico HTTP
    curl -X POST http://localhost:8080/tx

+-------------------------------------------------------------------------------+
|                       PASOS PARA EL ROLLBACK (FAILBACK)                       |
+-------------------------------------------------------------------------------+
| 1. Re-sincronizar db-primary desde db-replica (pg_basebackup)                 |
| 2. Encender db-primary en modo Standby (Read-Only)                            |
| 3. Promover db-primary de nuevo a Primario                                    |
| 4. Encender app-node-a para retomar el tráfico principal                      |
| 5. Re-convertir db-replica a Standby                                          |
+-------------------------------------------------------------------------------+

## Re-sincronizar db-primary desde db-replica

    # Levantar db-primary (Postgres fallará o quedará desfasado si no re-sincronizamos)
    docker start db-primary

    # Limpiar datos viejos en db-primary y clonar el estado actual de db-replica
    docker exec -it db-primary bash -c "
    rm -rf /var/lib/postgresql/data/*;
    PGPASSWORD=password123 pg_basebackup -h db-replica -D /var/lib/postgresql/data -U admin -v -P -X stream;
    touch /var/lib/postgresql/data/standby.signal;
    chown -R postgres:postgres /var/lib/postgresql/data;
    chmod 700 /var/lib/postgresql/data;
    "

    # Reiniciar db-primary para que entre en modo Standby siguiendo a db-replica
    docker restart db-primary

## Promover db-primary a Primario definitivo

    # Promover db-primary para que vuelva a aceptar escrituras
    docker exec -it db-primary su-exec postgres pg_ctl promote -D /var/lib/postgresql/data

    # Iniciar el backend App Node A
    docker start app-node-a

## Volver a convertir db-replica en Standby
    docker exec -it db-replica bash -c "
    rm -rf /var/lib/postgresql/data/*;
    PGPASSWORD=password123 pg_basebackup -h db-primary -D /var/lib/postgresql/data -U admin -v -P -X stream;
    touch /var/lib/postgresql/data/standby.signal;
    chown -R postgres:postgres /var/lib/postgresql/data;
    chmod 700 /var/lib/postgresql/data;
    "

    # Reiniciar la réplica & LB

    docker restart load-balancer app-node-a
    
## Verificación Final del Rollback

    curl -X POST http://localhost:8080/tx

    docker exec -it db-primary psql -U admin -d appdb -c "SELECT * FROM transacciones;"

    docker exec -it db-primary psql -U admin -d appdb -c "SELECT * FROM transacciones;"

    docker exec -it db-replica psql -U admin -d appdb -c "SELECT * FROM transacciones;"