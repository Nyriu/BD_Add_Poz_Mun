const logger = require('../lib/logger');
const pool = require('../lib/dbAuth');
const translations = require('../lib/translations');
const { convertEntitiesToSingular, getEntityKeys } = require('../lib/entities');


const controller = {

  getHome(req, res) {
    res.render('pages/index');
  },

  getEntities(req, res) {
    // Prende l'entità interessata dall'indirizzo
    const { entities } = req.params;
    const entity = convertEntitiesToSingular(entities);

    // Se l'indirizzo sbagliato fa un redirect alla home
    if (entity === undefined) {
      res.render('pages/index');
    } else {
      // query sulla tabella interessata
      pool.query(`SELECT * FROM ospedale.${entity}`, (err, queryRes) => {
        if (err) {
          throw err;
        }
        const data = queryRes.rows;
        const keys = getEntityKeys(entity);
        res.render('pages/entities.ejs', {
          entities,
          entity,
          keys,
          translations,
          data,
        });
      });
    }
  },

  getCreateEntity(req, res) {
    const { entities } = req.params;
    const entity = convertEntitiesToSingular(entities);
    if (entity === undefined) {
      res.render('pages/index');
    } else {
      const keys = getEntityKeys(entity);
      res.render('pages/createEntity.ejs', {
        entities,
        entity,
        keys,
        translations,
      });
    }
  },

  postCreateEntity(req, res) {
    logger.log('info', JSON.stringify(req.body));
    const { entities } = req.params;
    const entity = convertEntitiesToSingular(entities);
    if (entity === undefined) {
      res.render('pages/index');
    } else {
      let placeholders = '';
      const valuesArray = Object.values(req.body);
      for (let i = 0; i < valuesArray.length; i += 1) {
        placeholders += `$${i + 1}, `;
      }
      placeholders = placeholders.slice(0, -2);
      pool.query(`INSERT INTO ospedale.${entity} VALUES(${placeholders})`, valuesArray, (err) => {
        if (err) {
          throw err;
        }
        res.redirect(`/${entities}`);
      });
    }
  },

  getEntity(req, res) {
    const { entities, id } = req.params;
    const entity = convertEntitiesToSingular(entities);
    if (entity === undefined) {
      res.render('pages/index');
    } else {
      const keys = getEntityKeys(entity);
      pool.query(`SELECT * FROM ospedale.${entity} WHERE ${keys[0]} = $1`, [id], (err, queryRes) => {
        if (err) {
          throw err;
        }
        const data = queryRes.rows;
        res.render('pages/entity.ejs', {
          entities,
          entity,
          keys,
          translations,
          data,
        });
      });
    }
  },

  deleteEntity(req, res) {
    res.send('NOT IMPLEMENTED: ');
  },

  getUpdateEntity(req, res) {
    res.send('NOT IMPLEMENTED: ');
  },

  postUpdateEntity(req, res) {
    res.send('NOT IMPLEMENTED: ');
  },
};

module.exports = controller;
