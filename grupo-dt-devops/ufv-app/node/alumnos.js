const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || '10.0.1.10',
  user: process.env.DB_USER || 'backend_read',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'academico',
  port: 5432,
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ok', module: 'alumnos' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/alumnos', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT a.id, a.nombre, a.email, COUNT(i.id) AS asignaturas_inscritas
      FROM academico.alumnos a
      LEFT JOIN academico.inscripciones i ON i.alumno_id = a.id
      GROUP BY a.id, a.nombre, a.email
      ORDER BY a.id
      LIMIT 50
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`UFV alumnos service listening on ${PORT}`);
});
