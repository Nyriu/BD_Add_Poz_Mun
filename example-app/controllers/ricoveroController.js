const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'ricoveri';
const entity = 'ricovero';
const columns = ['cod_ric', 'data_i', 'data_f', 'motivo', 'div_osp', 'paziente'];

const controller = {

  getRicoveri(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.ricovero`, // query end
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

  getCreateRicovero(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreateRicovero(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.cod_ric,
      row.data_i,
      row.data_f,
      row.motivo,
      row.div_osp,
      row.paziente,
    ];
    pool.query(
      `INSERT INTO ospedale.ricovero
      VALUES($1, $2, $3, $4, $5, $6)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/ricoveri');
      },
    );
  },

  getRicovero(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.ricovero
      WHERE cod_ric = '${id}'`, // query end
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

  deleteRicovero(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.ricovero
      WHERE cod_ric = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/ricoveri');
      },
    );
  },

  getUpdateRicovero(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.ricovero
      WHERE cod_ric = '${id}'`, // query end
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

  postUpdateRicovero(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.data_i,
      row.data_f,
      row.motivo,
      row.div_osp,
      row.paziente,
    ];
    pool.query(
      `UPDATE ospedale.ricovero
      SET data_i = $1,
      data_f = $2,
      motivo = $3,
      div_osp = $4,
      paziente = $5
      WHERE cod_ric = '${id}'`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect(`/ricoveri/${id}`);
      },
    );
  },
};

module.exports = controller;
