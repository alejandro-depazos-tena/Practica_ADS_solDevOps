const express = require('express');
const path = require('path');
const { Pool } = require('pg');
const AWS = require('aws-sdk');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3001;
const SERVER_LABEL = process.env.SERVER_LABEL || 'Web E';
const PRIVATE_IP = process.env.PRIVATE_IP || '10.50.x.x';
const AWS_REGION = process.env.AWS_REGION || 'eu-south-2';
const S3_BUCKET = process.env.S3_BUCKET_NAME || 'dt-e-web-storage-906985802888-eu-south-2';
const s3 = new AWS.S3({ region: AWS_REGION });

function requiredEnv(name) {
  if (!process.env[name]) {
    throw new Error('Missing required environment variable: ' + name);
  }
  return process.env[name];
}

const pool = new Pool({
  host: process.env.DB_HOST || '10.20.1.221',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'DB_UFV',
  user: process.env.DB_USER || process.env.DB_USER_READ || 'backend_read',
  password: process.env.DB_PASSWORD || requiredEnv('DB_PASSWORD_READ'),
  connectionTimeoutMillis: 3000,
});

const writePool = new Pool({
  host: process.env.DB_HOST || '10.20.1.221',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'DB_UFV',
  user: process.env.DB_USER_WRITE || 'backend_write',
  password: requiredEnv('DB_PASSWORD_WRITE'),
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

function normalizeEntrega(row) {
  const alumnoNombre = [row.alumno_nombre, row.alumno_apellido].filter(Boolean).join(' ');

  return {
    id: row.id,
    practica_id: row.practica_id,
    practica: row.practica || (row.practica_id ? 'Practica #' + row.practica_id : '-'),
    alumno_id: row.alumno_id,
    alumno: alumnoNombre || (row.alumno_id ? 'Alumno #' + row.alumno_id : '-'),
    fecha_entrega: row.fecha_entrega,
    archivo_url: row.archivo_url,
    comentario: row.comentario,
    calificacion: row.calificacion,
    estado: row.estado || 'sin estado',
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

async function loadEntregas() {
  const result = await pool.query(`
    SELECT
      e.id,
      e.practica_id,
      e.alumno_id,
      e.fecha_entrega,
      e.archivo_url,
      e.comentario,
      e.calificacion,
      e.estado,
      p.titulo AS practica,
      a.nombre AS alumno_nombre,
      a.apellido AS alumno_apellido
    FROM entregas e
    LEFT JOIN practicas p ON p.id = e.practica_id
    LEFT JOIN alumnos a ON a.id = e.alumno_id
    ORDER BY e.id
    LIMIT 100
  `);

  return result.rows.map(normalizeEntrega);
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

app.get('/practicas/entregas', async (req, res) => {
  try {
    res.status(200).json(await loadEntregas());
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.post('/practicas/entregas', async (req, res) => {
  const practicaId = Number(req.body.practica_id);
  const alumnoId = Number(req.body.alumno_id);
  const archivoUrl = req.body.archivo_url || null;
  const comentario = req.body.comentario || null;
  const calificacion = req.body.calificacion === '' || req.body.calificacion == null
    ? null
    : Number(req.body.calificacion);
  const estado = req.body.estado || 'Entregada';

  if (!practicaId || !alumnoId) {
    return res.status(400).json({
      status: 'error',
      message: 'practica_id y alumno_id son obligatorios',
    });
  }

  try {
    const result = await writePool.query(`
      INSERT INTO entregas (practica_id, alumno_id, archivo_url, comentario, calificacion, estado)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `, [practicaId, alumnoId, archivoUrl, comentario, calificacion, estado]);

    res.status(201).json({
      status: 'ok',
      id: result.rows[0].id,
      message: 'Entrega registrada correctamente',
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/practicas/resumen', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) AS total_practicas,
        COUNT(*) FILTER (
          WHERE LOWER(COALESCE(estado, '')) LIKE '%entreg%'
             OR LOWER(COALESCE(estado, '')) LIKE '%complet%'
        ) AS entregadas,
        COUNT(*) FILTER (WHERE calificacion IS NOT NULL) AS calificadas,
        COUNT(*) FILTER (
          WHERE LOWER(COALESCE(estado, '')) NOT LIKE '%entreg%'
            AND LOWER(COALESCE(estado, '')) NOT LIKE '%complet%'
        ) AS pendientes
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

app.get('/practicas/s3/status', async (req, res) => {
  try {
    const output = await s3.listObjectsV2({
      Bucket: S3_BUCKET,
      Prefix: 'practicas/',
      MaxKeys: 10,
    }).promise();

    res.status(200).json({
      status: 'ok',
      bucket: S3_BUCKET,
      region: AWS_REGION,
      objects: (output.Contents || []).map((item) => ({
        key: item.Key,
        size: item.Size,
        last_modified: item.LastModified,
      })),
    });
  } catch (error) {
    res.status(500).json({ status: 'error', bucket: S3_BUCKET, message: error.message });
  }
});

app.post('/practicas/evidencias', async (req, res) => {
  const key = 'practicas/evidencias/evidencia-' + Date.now() + '.json';
  const body = {
    modulo: 'practicas',
    server: SERVER_LABEL,
    private_ip: PRIVATE_IP,
    created_at: new Date().toISOString(),
    data: req.body && Object.keys(req.body).length ? req.body : { accion: 'prueba-integracion-s3' },
  };

  try {
    await s3.putObject({
      Bucket: S3_BUCKET,
      Key: key,
      Body: JSON.stringify(body, null, 2),
      ContentType: 'application/json',
    }).promise();

    res.status(201).json({ status: 'ok', bucket: S3_BUCKET, key: key });
  } catch (error) {
    res.status(500).json({ status: 'error', bucket: S3_BUCKET, message: error.message });
  }
});

app.listen(PORT, () => {
  console.log('UFV practicas service listening on ' + PORT);
});
