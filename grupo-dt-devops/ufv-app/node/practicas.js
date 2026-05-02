const express = require('express');
const path = require('path');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3001;
const SERVER_LABEL = process.env.SERVER_LABEL || 'Web E';
const PRIVATE_IP = process.env.PRIVATE_IP || '10.50.x.x';

const pool = new Pool({
  host: process.env.DB_HOST || '10.20.1.221',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'DB_UFV',
  user: process.env.DB_USER || 'backend_read',
  password: process.env.DB_PASSWORD || 'PassRead1!',
  connectionTimeoutMillis: 3000,
});

function normalizePractica(row) {
  const alumnoNombre = [row.alumno_nombre, row.alumno_apellido].filter(Boolean).join(' ');
  const profesorNombre = [row.profesor_nombre, row.profesor_apellido].filter(Boolean).join(' ');

  return {
    id: row.id,
    titulo: row.titulo,
    descripcion: row.descripcion,
    alumno_id: row.alumno_id,
    profesor_id: row.profesor_id,
    alumno: alumnoNombre || (row.alumno_id ? 'Alumno #' + row.alumno_id : '-'),
    profesor: profesorNombre || (row.profesor_id ? 'Profesor #' + row.profesor_id : '-'),
    fecha_entrega: row.fecha_entrega,
    calificacion: row.calificacion,
    estado: row.estado || 'sin estado',
    fecha_creacion: row.fecha_creacion,
  };
}

async function loadPracticas() {
  const result = await pool.query(`
    SELECT
      p.id,
      p.titulo,
      p.descripcion,
      p.alumno_id,
      p.profesor_id,
      p.fecha_entrega,
      p.calificacion,
      p.estado,
      p.fecha_creacion,
      a.nombre AS alumno_nombre,
      a.apellido AS alumno_apellido,
      pr.nombre AS profesor_nombre,
      pr.apellido AS profesor_apellido
    FROM practicas p
    LEFT JOIN alumnos a ON a.id = p.alumno_id
    LEFT JOIN profesores pr ON pr.id = p.profesor_id
    ORDER BY p.id
    LIMIT 100
  `);

  return result.rows.map(normalizePractica);
}

app.get(['/practicas', '/practicas/'], (req, res) => {
  res.sendFile(path.join(__dirname, 'practicas.html'));
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({
      status: 'ok',
      module: 'practicas',
      server: SERVER_LABEL,
      private_ip: PRIVATE_IP,
      db_host: process.env.DB_HOST || '10.20.1.221',
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      module: 'practicas',
      server: SERVER_LABEL,
      message: error.message,
    });
  }
});

app.get('/practicas/lista', async (req, res) => {
  try {
    res.status(200).json(await loadPracticas());
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/practicas/resumen', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) AS total_practicas,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(estado, '')) LIKE '%entreg%') AS entregadas,
        COUNT(*) FILTER (WHERE calificacion IS NOT NULL) AS calificadas,
        COUNT(*) FILTER (WHERE LOWER(COALESCE(estado, '')) NOT LIKE '%entreg%') AS pendientes
      FROM practicas
    `);

    res.status(200).json({
      total_practicas: Number(result.rows[0].total_practicas || 0),
      entregadas: Number(result.rows[0].entregadas || 0),
      calificadas: Number(result.rows[0].calificadas || 0),
      pendientes: Number(result.rows[0].pendientes || 0),
      server: SERVER_LABEL,
      private_ip: PRIVATE_IP,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.listen(PORT, () => {
  console.log('UFV practicas service listening on ' + PORT);
});
