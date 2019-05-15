const router = require('express').Router();
const {
  getPazienti,
  getCreatePaziente,
  postCreatePaziente,
  getPaziente,
  deletePaziente,
  getUpdatePaziente,
  postUpdatePaziente,
} = require('../../controllers/pazienteController');

router.get('/', getPazienti);

router.get('/create', getCreatePaziente);

router.post('/create', postCreatePaziente);

router.get('/:id', getPaziente);

router.post('/:id/delete', deletePaziente);

router.get('/:id/update', getUpdatePaziente);

router.post('/:id/update', postUpdatePaziente);

module.exports = router;
