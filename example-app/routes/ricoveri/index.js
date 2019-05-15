const router = require('express').Router();
const {
  getRicoveri,
  getCreateRicovero,
  postCreateRicovero,
  getRicovero,
  deleteRicovero,
  getUpdateRicovero,
  postUpdateRicovero,
} = require('../../controllers/ricoveroController');

router.get('/', getRicoveri);

router.get('/create', getCreateRicovero);

router.post('/create', postCreateRicovero);

router.get('/:id', getRicovero);

router.post('/:id/delete', deleteRicovero);

router.get('/:id/update', getUpdateRicovero);

router.post('/:id/update', postUpdateRicovero);

module.exports = router;
