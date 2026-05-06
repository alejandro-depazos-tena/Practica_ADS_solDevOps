const express = require('express');
const { Pool } = require('pg');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const path = require('path');

const app = express();
app.use(express.json());

const s3 = new S3Client({ region: process.env.AWS_REGION || 'eu-south-2' });
const S3_BUCKET = process.env.S3_BUCKET_NAME || 'dt-d-web-storage-544719091320-eu-south-2';

function requiredEnv(name) {
  if (!process.env[name]) {
    throw new Error('Missing required environment variable: ' + name);
  }
  return process.env[name];
}

async function guardarRegistroS3(tipo, datos) {
  const registro = { tipo, datos, fecha: new Date().toISOString(), modulo: 'alumnos' };
  const key = `alumnos/${tipo}-${Date.now()}.json`;
  await s3.send(new PutObjectCommand({
    Bucket: S3_BUCKET,
    Key: key,
    Body: JSON.stringify(registro),
    ContentType: 'application/json'
  }));
}

const pool = new Pool({
  host: process.env.DB_HOST || '10.20.1.221',
  user: process.env.DB_USER || 'backend_read',
  password: requiredEnv('DB_PASSWORD'),
  database: process.env.DB_NAME || 'DB_UFV',
  port: 5432,
  connectionTimeoutMillis: 5000,
});

app.get('/alumnos', (req, res) => {
  res.sendFile(path.join(__dirname, 'alumnos.html'));
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ok', module: 'alumnos' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/alumnos/lista', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, nombre, apellido, email, carrera, curso, fecha_registro
      FROM alumnos
      ORDER BY id
      LIMIT 50
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/alumnos/:id/detalle', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT id, nombre, apellido, email, carrera, curso, fecha_registro
      FROM alumnos
      WHERE id = $1
    `, [id]);
    if (!result.rows.length) {
      return res.status(404).json({ status: 'error', message: 'Alumno no encontrado' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/alumnos/buscar', async (req, res) => {
  try {
    const { carrera, curso } = req.query;
    let query = 'SELECT id, nombre, apellido, email, carrera, curso, fecha_registro FROM alumnos WHERE 1=1';
    const params = [];
    if (carrera) { params.push(carrera); query += ` AND carrera = $${params.length}`; }
    if (curso) { params.push(curso); query += ` AND curso = $${params.length}`; }
    query += ' ORDER BY apellido, nombre LIMIT 50';
    const result = await pool.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.post('/alumnos/nuevo', async (req, res) => {
  try {
    const { nombre, apellido, email, carrera, curso } = req.body;
    if (!nombre || !apellido || !email) {
      return res.status(400).json({ status: 'error', message: 'nombre, apellido y email son obligatorios' });
    }
    const result = await pool.query(`
      INSERT INTO alumnos (nombre, apellido, email, carrera, curso)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id
    `, [nombre, apellido, email, carrera, curso]);
    await guardarRegistroS3('nuevo-alumno', { id: result.rows[0].id, nombre, apellido, email });
    res.status(201).json({ status: 'ok', id: result.rows[0].id, message: 'Alumno registrado correctamente' });
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ status: 'error', message: 'Ya existe un alumno con ese email' });
    }
    res.status(500).json({ status: 'error', message: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`UFV alumnos service listening on ${PORT}`);
});
