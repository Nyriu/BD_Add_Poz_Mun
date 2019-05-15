const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'terapie-prescritte';
const entity = 'terapie prescritta';
const columns = ['data_i', 'data_f', 'med_presc', 'diagnosi', 'terapia', 'coll_dia'];


// TODO FIX THINGS AND LINK
/*
opzioni
/id-diagnosi/id-terapia/... <-- seems nice
/id-dia-id-terapia/...
/id ?

*/


const controller = {

  getTerapiePrescritte(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.terapia_prescritta`, // query end
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

  getCreateTerapiaPrescritta(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreateTerapiaPrescritta(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.data_i,
      row.data_f,
      row.med_presc,
      row.diagnosi,
      row.terapia,
      row.coll_dia,
    ];
    pool.query(
      `INSERT INTO ospedale.terapia_prescritta
      VALUES($1, $2, $3, $4, $6)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/terapie-prescritte');
      },
    );
  },

  getTerapiaPrescritta(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.terapia_prescritta
      WHERE diagnosi = '${id}'`, // query end
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

  deleteTerapiaPrescritta(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.terapia_prescritta
      WHERE cod_ric = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/terapie-prescritte');
      },
    );
  },

  getUpdateTerapiaPrescritta(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.terapia_prescritta
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

  postUpdateTerapiaPrescritta(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.data_i,
      row.data_f,
      row.med_presc,
      row.diagnosi,
      row.terapia,
      row.coll_dia,
    ];
    pool.query(
      `UPDATE ospedale.terapia_prescritta
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
        res.redirect(`/terapie-prescritte/${id}`);
      },
    );
  },
};

module.exports = controller;
