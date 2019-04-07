const express = require('express');

const router = express.Router();

const {
  getPazienti,
  getCreatePaziente,
  postCreatePaziente,
  deletePaziente,
  postUpdatePaziente,
  getPaziente,
} = require('../controllers/pazienteController');

router.get('/', getPazienti);

router.get('/create', getCreatePaziente);

router.post('/create', postCreatePaziente);

router.delete('/:id/delete', deletePaziente);

router.post('/:id/update', postUpdatePaziente);

router.get('/:id', getPaziente);

module.exports = router;
