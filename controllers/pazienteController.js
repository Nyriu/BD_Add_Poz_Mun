const logger = require('../lib/logger');

const pazienteController = {

  getPazienti(req, res) {
    // TODO delete this example
    const data = [{ id: '0', firstName: 'Paolo', lastName: 'Addis' }, { id: '1', firstName: 'Samuele', lastName: 'Poz' }, { id: '2', firstName: 'Tristano', lastName: 'Munini' }];
    res.render('pages/pazienti.ejs', {
      data,
    });
  },

  getCreatePaziente(req, res) {
    res.render('pages/paziente.ejs');
  },

  postCreatePaziente(req, res) {
    logger.log('info', JSON.stringify(req.body));
    res.send('NOT IMPLEMENTED: postCreatePaziente, check terminal');
  },

  deletePaziente(req, res) {
    res.send('NOT IMPLEMENTED: deletePaziente');
  },

  postUpdatePaziente(req, res) {
    res.send('NOT IMPLEMENTED: postUpdatePaziente');
  },

  getPaziente(req, res) {
    res.send('NOT IMPLEMENTED: getPaziente');
  },
};

module.exports = pazienteController;
