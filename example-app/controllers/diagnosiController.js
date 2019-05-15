const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'diagnosi';
const entity = 'diagnosi';
const columns = ['cod_dia', 'data_dia', 'cod_pat', 'grav_pat', 'medico', 'paziente', 'ricovero'];

const controller = {

  getAllDiagnosi(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.diagnosi`, // query end
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

  getCreateDiagnosi(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreateDiagnosi(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.cod_dia,
      row.data_dia,
      row.cod_pat,
      row.grav_pat,
      row.medico,
      row.paziente,
      row.ricovero,
    ];
    pool.query(
      `INSERT INTO ospedale.diagnosi
      VALUES($1, $2, $3, $4, $6, $7)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/diagnosi');
      },
    );
  },

  getDiagnosi(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.diagnosi
      WHERE cod_dia = '${id}'`, // query end
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

  deleteDiagnosi(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.diagnosi
      WHERE cod_dia = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/diagnosi');
      },
    );
  },

  getUpdateDiagnosi(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.diagnosi
      WHERE cod_dia = '${id}'`, // query end
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

  postUpdateDiagnosi(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.data_dia,
      row.cod_pat,
      row.grav_pat,
      row.medico,
      row.paziente,
      row.ricovero,
    ];
    pool.query(
      `UPDATE ospedale.diagnosi
      SET data_dia = $1,
      cod_pat = $2,
      grav_pat = $3,
      medico = $4,
      paziente = $5,
      ricovero = $6
      WHERE cod_dia = '${id}'`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect(`/diagnosi/${id}`);
      },
    );
  },
};

module.exports = controller;
