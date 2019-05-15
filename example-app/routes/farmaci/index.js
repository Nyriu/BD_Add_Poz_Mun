const router = require('express').Router();
const {
  getFarmaci,
  getCreateFarmaco,
  postCreateFarmaco,
  getFarmaco,
  deleteFarmaco,
  getUpdateFarmaco,
  postUpdateFarmaco,
} = require('../../controllers/farmacoController');

router.get('/', getFarmaci);

router.get('/create', getCreateFarmaco);

router.post('/create', postCreateFarmaco);

router.get('/:id', getFarmaco);

router.post('/:id/delete', deleteFarmaco);

router.get('/:id/update', getUpdateFarmaco);

router.post('/:id/update', postUpdateFarmaco);

module.exports = router;
