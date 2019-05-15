const router = require('express').Router();
const {
  getTerapiePrescritte,
  getCreateTerapiaPrescritta,
  postCreateTerapiaPrescritta,
  getTerapiaPrescritta,
  deleteTerapiaPrescritta,
  getUpdateTerapiaPrescritta,
  postUpdateTerapiaPrescritta,
} = require('../../controllers/terapiaPrescrittaController');

router.get('/', getTerapiePrescritte);

router.get('/create', getCreateTerapiaPrescritta);

router.post('/create', postCreateTerapiaPrescritta);

router.get('/:id', getTerapiaPrescritta);

router.post('/:id/delete', deleteTerapiaPrescritta);

router.get('/:id/update', getUpdateTerapiaPrescritta);

router.post('/:id/update', postUpdateTerapiaPrescritta);

module.exports = router;
