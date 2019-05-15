const router = require('express').Router();
const {
  getTerapie,
  getCreateTerapia,
  postCreateTerapia,
  getTerapia,
  deleteTerapia,
  getUpdateTerapia,
  postUpdateTerapia,
} = require('../../controllers/terapiaController');

router.get('/', getTerapie);

router.get('/create', getCreateTerapia);

router.post('/create', postCreateTerapia);

router.get('/:id', getTerapia);

router.post('/:id/delete', deleteTerapia);

router.get('/:id/update', getUpdateTerapia);

router.post('/:id/update', postUpdateTerapia);

module.exports = router;
