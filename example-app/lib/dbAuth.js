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
  user: 'bd_18_paolo_addis',
  host: '158.110.145.186',
  database: 'bd_18_paolo_addis',
  password: 'corso_bd_2018',
  port: 5432,
});

// wish this worked better ...
pool.query("SET SCHEMA 'ospedale'", (err) => {
  if (err) {
    throw err;
  }
});


module.exports = pool;
