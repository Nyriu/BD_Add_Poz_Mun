const router = require('express').Router();
const {
  getHome,
  getEntities,
  getCreateEntity,
  postCreateEntity,
  getEntity,
  deleteEntity,
  getUpdateEntity,
  postUpdateEntity,
} = require('../controllers');

router.get('/', getHome);

router.get('/:entities', getEntities);

router.get('/:entities/create', getCreateEntity);

router.post('/:entities/create', postCreateEntity);

router.get('/:entities/:id', getEntity);

router.delete('/:entities/:id/delete', deleteEntity);

router.get('/:entities/:id/update', getUpdateEntity);

router.post('/:entities/:id/update', postUpdateEntity);

module.exports = router;
