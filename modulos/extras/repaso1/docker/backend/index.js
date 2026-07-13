const express = require('express');
const { Pool } = require('pg'); // Driver para conectar con PostgreSQL
const app = express();

// Middleware para procesar cuerpos de petición en formato JSON
app.use(express.json());

// 1. Configuración del Pool de conexiones
// Utilizamos variables de entorno para cumplir con las mejores prácticas de seguridad (12-Factor App)
const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  port: 5432,
});

// 2. Inicialización de la base de datos
// Creamos la tabla al arrancar si no existe. Esto garantiza que la app sea "auto-configurable"
async function initDb() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS registros (
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(100),
        clase VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("Infraestructura: Tabla 'registros' lista.");
  } catch (err) {
    console.error("Error al inicializar la base de datos:", err);
  }
}
initDb();

// 3. Endpoint POST: Crear nuevos registros
// Aquí demostramos cómo la API persiste datos en el almacenamiento externo
app.post('/api/data', async (req, res) => {
  const { nombre, clase } = req.body;
  try {
    const query = 'INSERT INTO registros (nombre, clase) VALUES ($1, $2) RETURNING *';
    const result = await pool.query(query, [nombre, clase]);
    res.status(201).json({ message: "Dato guardado con éxito", data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: "Error al guardar en DB: " + err.message });
  }
});

// 4. Endpoint GET: Consultar registros existentes
// Fundamental para demostrar que los datos sobreviven incluso si reiniciamos los pods
app.get('/api/data', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM registros ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "Error al consultar la DB: " + err.message });
  }
});

// Iniciar servidor
app.listen(3000, () => {
  console.log('Backend iniciado en el puerto 3000');
});