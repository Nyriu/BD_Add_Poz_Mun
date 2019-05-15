const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');

const entities = 'pazienti';
const entity = 'paziente';
const columns = ['cf', 'cognome', 'nome', 'data_nasc', 'luogo_nasc', 'prov_res', 'reg_app', 'ulss', 'tot_gg_ric'];

const controller = {

  getPazienti(req, res) {
    pool.query(
      `SELECT * 
      FROM ospedale.paziente`, // query end
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

  getCreatePaziente(req, res) {
    res.render('pages/createEntity.ejs', {
      entities,
      entity,
      columns,
      translations,
    });
  },

  postCreatePaziente(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.cf,
      row.cognome,
      row.nome,
      row.data_nasc,
      row.luogo_nasc,
      row.prov_res,
      row.reg_app,
      row.ulss,
      row.tot_gg_ric,
    ];
    pool.query(
      `INSERT INTO ospedale.paziente
      VALUES($1, $2, $3, $4, $6, $7, $8, $9)`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/pazienti');
      },
    );
  },

  getPaziente(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.paziente
      WHERE cf = '${id}'`, // query end
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

  deletePaziente(req, res) {
    const { id } = req.params;
    pool.query(
      `DELETE FROM ospedale.paziente
      WHERE cf = '${id}'`, // query end
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect('/pazienti');
      },
    );
  },

  getUpdatePaziente(req, res) {
    const { id } = req.params;
    pool.query(
      `SELECT *
      FROM ospedale.paziente
      WHERE cf = '${id}'`, // query end
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

  postUpdatePaziente(req, res) {
    const { id } = req.params;
    logger.log('info', JSON.stringify(req.body));
    const row = {};
    columns.forEach((column) => {
      row[column] = (typeof req.body[column] === 'undefined' || req.body[column] === '') ? null : req.body[column];
    });
    const values = [
      row.cognome,
      row.nome,
      row.data_nasc,
      row.luogo_nasc,
      row.prov_res,
      row.reg_app,
      row.ulss,
      row.tot_gg_ric,
    ];
    pool.query(
      `UPDATE ospedale.paziente
      SET cognome = $1,
      nome = $2,
      data_nasc = $3,
      luogo_nasc = $4,
      prov_res = $5,
      reg_app = $6,
      ulss = $7,
      tot_gg_ric = $8
      WHERE cf = '${id}'`, // query end
      values,
      (err, queryRes) => {
        if (err) {
          throw err;
        }
        logger.log('info', queryRes);
        res.redirect(`/pazienti/${id}`);
      },
    );
  },
};

module.exports = controller;
