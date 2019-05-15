const {
  Pool,
} = require('pg');

// heroku config
/*
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true,
});
*/

// local config
const pool = new Pool({
  user: 'appuniuser',
  host: 'localhost',
  database: 'appuni',
  password: 'appunipassword',
  port: 5432,
});

// wish this worked better ...
pool.query("SET SCHEMA 'ospedale'", (err) => {
  if (err) {
    throw err;
  }
});


module.exports = pool;
