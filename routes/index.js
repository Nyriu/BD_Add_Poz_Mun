const router = require('express').Router();
const pazienti = require('./pazienti');
const indexController = require('../controllers/indexController');

router.get('/', indexController.getIndex);
router.use('/pazienti', pazienti);

module.exports = router;
