const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || '10.0.1.10',
  user: process.env.DB_USER || 'backend_read',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'academico',
  port: 5432,
  connectionTimeoutMillis: 5000,
});

app.get('/practicas', (req, res) => {
  res.sendFile(path.join(__dirname, 'practicas.html'));
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ok', module: 'practicas' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/practicas/lista', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT p.id, p.titulo, p.asignatura, p.descripcion,
             COUNT(e.id) AS entregas_registradas,
             COUNT(e.id) FILTER (WHERE e.estado = 'entregado') AS entregas_completadas
      FROM academico.practicas p
      LEFT JOIN academico.entregas e ON e.practica_id = p.id
      GROUP BY p.id, p.titulo, p.asignatura, p.descripcion
      ORDER BY p.id
      LIMIT 50
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/practicas/entregas', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT e.id, p.titulo AS practica, a.nombre AS alumno,
             e.estado, e.fecha_entrega
      FROM academico.entregas e
      JOIN academico.practicas p ON p.id = e.practica_id
      JOIN academico.alumnos a ON a.id = e.alumno_id
      ORDER BY e.fecha_entrega DESC
      LIMIT 50
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/practicas/resumen', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM academico.practicas) AS total_practicas,
        (SELECT COUNT(*) FROM academico.entregas) AS total_entregas,
        (SELECT COUNT(*) FROM academico.entregas WHERE estado = 'entregado') AS entregas_completadas,
        (SELECT COUNT(DISTINCT alumno_id) FROM academico.entregas) AS alumnos_con_entregas
    `);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`UFV practicas service listening on ${PORT}`);
});
