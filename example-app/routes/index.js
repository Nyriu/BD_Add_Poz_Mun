const router = require('express').Router();
const { getHome } = require('../controllers');
const pazienteRouter = require('./pazienti');
const diagnosiRouter = require('./diagnosi');
const ricoveroRouter = require('./ricoveri');
const farmacoRouter = require('./farmaci');
const terapiaRouter = require('./terapie');
const terapiaPrescrittaRouter = require('./terapie-prescritte');


router.get('/', getHome);

router.use('/pazienti', pazienteRouter);
router.use('/diagnosi', diagnosiRouter);
router.use('/ricoveri', ricoveroRouter);
router.use('/farmaci', farmacoRouter);
router.use('/terapie', terapiaRouter);
router.use('/terapie-prescritte', terapiaPrescrittaRouter);


module.exports = router;
