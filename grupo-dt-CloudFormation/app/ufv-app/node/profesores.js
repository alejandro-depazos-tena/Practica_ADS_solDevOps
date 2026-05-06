const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
app.use(express.json());

const dbConfig = {
  host: process.env.DB_HOST || '10.20.1.221',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'DB_UFV',
};

function requiredEnv(name) {
  if (!process.env[name]) {
    throw new Error('Missing required environment variable: ' + name);
  }
  return process.env[name];
}

const readPool = new Pool({
  ...dbConfig,
  user: process.env.DB_USER || process.env.DB_USER_READ || 'backend_read',
  password: process.env.DB_PASSWORD || requiredEnv('DB_PASSWORD_READ'),
});

const writePool = new Pool({
  ...dbConfig,
  user: process.env.DB_WRITE_USER || process.env.DB_USER_WRITE || process.env.DB_USER || 'backend_write',
  password: process.env.DB_WRITE_PASSWORD || process.env.DB_PASSWORD_WRITE || process.env.DB_PASSWORD || requiredEnv('DB_PASSWORD_WRITE'),
});

const PORT = process.env.PORT || 3001;
const SERVER_LABEL = process.env.SERVER_LABEL || 'Web C';
const PRIVATE_IP = process.env.PRIVATE_IP || '10.30.x.x';

app.get(['/profesores', '/profesores/'], (req, res) => {
  res.sendFile(path.join(__dirname, 'profesores.html'));
});

async function handleHealth(req, res) {
  try {
    await readPool.query('SELECT 1');
    res.status(200).json({
      status: 'ok',
      module: 'profesores',
      server: SERVER_LABEL,
      private_ip: PRIVATE_IP,
      db_host: dbConfig.host,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', module: 'profesores', message: error.message });
  }
}

app.get('/health', handleHealth);
app.get('/profesores/health', handleHealth);

function buildFilters(query) {
  const conditions = [];
  const values = [];

  if (query.departamento) {
    values.push(query.departamento);
    conditions.push(`departamento = $${values.length}`);
  }

  if (query.especialidad) {
    values.push(query.especialidad);
    conditions.push(`especialidad = $${values.length}`);
  }

  return { conditions, values };
}

async function loadProfesores(query) {
  const { conditions, values } = buildFilters(query);
  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await readPool.query(`
    SELECT id, nombre, email, departamento, especialidad, fecha_alta
    FROM profesores
    ${where}
    ORDER BY id
    LIMIT 100
  `, values);

  return result.rows;
}

app.get('/profesores/lista', async (req, res) => {
  try {
    res.status(200).json(await loadProfesores(req.query));
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores/buscar', async (req, res) => {
  try {
    res.status(200).json(await loadProfesores(req.query));
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.get('/profesores/resumen', async (req, res) => {
  try {
    const result = await readPool.query(`
      SELECT
        COUNT(*) AS total_profesores,
        COUNT(DISTINCT departamento) AS departamentos,
        COUNT(DISTINCT especialidad) AS especialidades
      FROM profesores
    `);

    const row = result.rows[0] || {};
    res.status(200).json({
      total_profesores: Number(row.total_profesores || 0),
      departamentos: Number(row.departamentos || 0),
      especialidades: Number(row.especialidades || 0),
      server: SERVER_LABEL,
      private_ip: PRIVATE_IP,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.post('/profesores/nuevo', async (req, res) => {
  try {
    const { nombre, apellido, email, departamento, especialidad } = req.body;
    if (!nombre || !apellido || !email || !departamento || !especialidad) {
      return res.status(400).json({
        status: 'error',
        message: 'nombre, apellido, email, departamento y especialidad son obligatorios',
      });
    }

    const result = await writePool.query(`
      INSERT INTO profesores (nombre, apellido, email, departamento, especialidad)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id
    `, [nombre, apellido, email, departamento, especialidad]);

    res.status(201).json({ status: 'ok', id: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`UFV profesores service listening on ${PORT}`);
});
