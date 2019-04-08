const { Pool } = require('pg');

/* const pool = new Pool({
  user: 'appuniuser',
  host: 'localhost',
  database: 'appuni',
  password: 'appunipassword',
  port: 5432,
}); */

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true,
});

module.exports = pool;
