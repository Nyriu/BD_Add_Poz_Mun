const router = require('express').Router();
const {
  getAllDiagnosi,
  getCreateDiagnosi,
  postCreateDiagnosi,
  getDiagnosi,
  deleteDiagnosi,
  getUpdateDiagnosi,
  postUpdateDiagnosi,
} = require('../../controllers/diagnosiController');

router.get('/', getAllDiagnosi);

router.get('/create', getCreateDiagnosi);

router.post('/create', postCreateDiagnosi);

router.get('/:id', getDiagnosi);

router.post('/:id/delete', deleteDiagnosi);

router.get('/:id/update', getUpdateDiagnosi);

router.post('/:id/update', postUpdateDiagnosi);

module.exports = router;
