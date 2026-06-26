const express = require('express');
const cors = require('cors');
const { Client } = require('pg');

const app = express();
app.use(cors());

// URL de conexión inyectada dinámicamente mediante variables de entorno
const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:secret123@localhost:5432/postgres';

app.get('/api/data', async (req, res) => {
    let dbStatus = "Desconectado";

    // Intentamos hacer una consulta a PostgreSQL para validar conectividad
    const client = new Client({ connectionString });
    try {
        await client.connect();
        const response = await client.query('SELECT NOW()');
        dbStatus = "Conexión Exitosa con PostgreSQL";
    } catch (err) {
        dbStatus = `Error de Conexión: ${err.message}`;
    } finally {
        await client.end();
    }

    res.json({
        mensaje: "¡Hola desde la API empaquetada en Docker!",
        db_status: dbStatus
    });
});

app.listen(3000, () => {
    console.log("Servidor Backend corriendo en puerto 3000");
});
