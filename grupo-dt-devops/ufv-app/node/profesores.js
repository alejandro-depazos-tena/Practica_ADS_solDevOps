const express = require('express');
const { Pool } = require('pg');
const path = require('path');
const { S3Client, ListObjectsV2Command } = require('@aws-sdk/client-s3');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || '10.0.1.10',
  user: process.env.DB_USER || 'backend_read',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'academico',
  port: 5432,
});

const s3BucketName = process.env.S3_BUCKET_NAME;
const s3Client = new S3Client({});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ok' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores', (req, res) => {
  res.sendFile(path.join(__dirname, 'profesores.html'));
});

async function getAsignaturas() {
  const result = await pool.query(`
    SELECT
      a.id,
      a.nombre,
      a.descripcion,
      a.creditos,
      a.fecha_creacion,
      COUNT(i.id) AS inscritos,
      ROUND(AVG(i.nota)::numeric, 2) AS nota_media
    FROM academico.asignaturas a
    LEFT JOIN academico.inscripciones i ON i.asignatura_id = a.id
    GROUP BY a.id, a.nombre, a.descripcion, a.creditos, a.fecha_creacion
    ORDER BY a.id
    LIMIT 50
  `);

  return result.rows;
}

app.get('/profesores/asignaturas', async (req, res) => {
  try {
    res.json(await getAsignaturas());
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores/lista', async (req, res) => {
  try {
    res.json(await getAsignaturas());
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores/inscripciones', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        i.id,
        i.nota,
        i.alumno_id,
        i.asignatura_id,
        a.nombre AS asignatura,
        al.nombre AS alumno_nombre,
        al.email AS alumno_email
      FROM academico.inscripciones i
      JOIN academico.asignaturas a ON a.id = i.asignatura_id
      JOIN academico.alumnos al ON al.id = i.alumno_id
      ORDER BY i.id DESC
      LIMIT 50
    `);

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores/resumen', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        COUNT(*) AS total_asignaturas,
        (SELECT COUNT(*) FROM academico.inscripciones) AS total_inscripciones,
        ROUND(AVG(i.nota)::numeric, 2) AS nota_media
      FROM academico.asignaturas a
      LEFT JOIN academico.inscripciones i ON i.asignatura_id = a.id
    `);

    const row = result.rows[0] || {};
    res.status(200).json({
      total_asignaturas: Number(row.total_asignaturas || 0),
      total_inscripciones: Number(row.total_inscripciones || 0),
      nota_media: row.nota_media,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/s3/objects', async (req, res) => {
  if (!s3BucketName) {
    return res.status(400).json({
      status: 'error',
      message: 'S3_BUCKET_NAME no configurado en el entorno del servicio',
    });
  }

  try {
    const output = await s3Client.send(new ListObjectsV2Command({
      Bucket: s3BucketName,
      MaxKeys: 20,
    }));

    const objects = (output.Contents || []).map((item) => ({
      key: item.Key,
      size: item.Size,
      lastModified: item.LastModified,
    }));

    return res.status(200).json({
      status: 'ok',
      bucket: s3BucketName,
      objects,
    });
  } catch (error) {
    return res.status(500).json({ status: 'error', message: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`UFV node service listening on ${PORT}`);
});
