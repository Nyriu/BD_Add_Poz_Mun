const pazienteController = {

  getPazienti(req, res) {
    // TODO delete this example
    const data = [{ id: '0', firstName: 'Paolo', lastName: 'Addis' }, { id: '1', firstName: 'Samuele', lastName: 'Poz' }, { id: '2', firstName: 'Tristano', lastName: 'Munini' }];
    res.render('pages/pazienti.ejs', {
      data,
    });
  },

  postCreatePaziente(req, res) {
    res.send('NOT IMPLEMENTED: postCreatePaziente');
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
