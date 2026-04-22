const express = require('express');
const { Pool } = require('pg');
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

app.get('/profesores', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, nombre FROM academico.asignaturas ORDER BY id LIMIT 50');
    res.json(result.rows);
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
