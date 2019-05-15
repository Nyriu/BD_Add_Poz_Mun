const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'terapie';
const entity = 'terapia';
const columns = ['cod_ter', 'dose_gio', 'mod_somm', 'farmaco'];

const controller = {

  getTerapie(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.terapia`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        const data = queryRes.rows;
        res.render('pages/entities.ejs', {
          entities,
          entity,
          columns,
          translations,
          data,
        });
      },
    );
  },

  getCreateTerapia(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreateTerapia(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.cod_ter,
      row.dose_gio,
      row.mod_somm,
      row.farmaco,
    ];
    pool.query(
      `INSERT INTO ospedale.terapia
      VALUES($1, $2, $3, $4, $6)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/terapie');
      },
    );
  },

  getTerapia(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.terapia
      WHERE cod_ter = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        const data = queryRes.rows;
        res.render('pages/entity.ejs', {
          entities,
          entity,
          columns,
          translations,
          data,
        });
      },
    );
  },

  deleteTerapia(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.terapia
      WHERE cod_ter = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/terapie');
      },
    );
  },

  getUpdateTerapia(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.terapia
      WHERE cod_ter = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        const data = queryRes.rows;
        res.render('pages/updateEntity.ejs', {
          entities,
          entity,
          columns,
          translations,
          data,
        });
      },
    );
  },

  postUpdateTerapia(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.dose_gio,
      row.mod_somm,
      row.farmaco,
    ];
    pool.query(
      `UPDATE ospedale.terapia
      SET dose_gio = $1,
      mod_somm = $2,
      farmaco = $3
      WHERE cod_ter = '${id}'`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect(`/terapie/${id}`);
      },
    );
  },
};

module.exports = controller;
