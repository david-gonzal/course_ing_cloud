CREATE TABLE IF NOT EXISTS transacciones (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL
);

-- Permisos para replicación del usuario admin
ALTER USER admin WITH REPLICATION;