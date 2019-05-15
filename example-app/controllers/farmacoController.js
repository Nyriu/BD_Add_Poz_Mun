const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'farmaci';
const entity = 'farmaco';
const columns = ['nome_comm', 'azienda_prod', 'dose_gg_racc'];

const controller = {

  getFarmaci(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.farmaco`, // query end
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

  getCreateFarmaco(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreateFarmaco(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.nome_comm,
      row.azienda_prod,
      row.dose_gg_racc,
    ];
    pool.query(
      `INSERT INTO ospedale.farmaco
      VALUES($1, $2, $3)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/farmaci');
      },
    );
  },

  getFarmaco(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.farmaco
      WHERE nome_comm = '${id}'`, // query end
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

  deleteFarmaco(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.farmaco
      WHERE nome_comm = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/farmaci');
      },
    );
  },

  getUpdateFarmaco(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.farmaco
      WHERE nome_comm = '${id}'`, // query end
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

  postUpdateFarmaco(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.azienda_prod,
      row.dose_gg_racc,
    ];
    pool.query(
      `UPDATE ospedale.farmaco
      SET azienda_prod = $1,
      dose_gg_racc = $2
      WHERE nome_comm = '${id}'`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect(`/farmaci/${id}`);
      },
    );
  },
};

module.exports = controller;
