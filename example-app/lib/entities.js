function convertEntitiesToSingular(entities) {
  const obj = {
    pazienti: 'paziente',
    ricoveri: 'ricovero',
    diagnosi: 'diagnosi',
  };
  return obj[entities];
}

function getEntityKeys(entity) {
  let fields = [];
  switch (entity) {
    case 'paziente':
      fields = [
        'cf',
        'cognome',
        'nome',
        'data_nasc',
        'luogo_nasc',
        'prov_res',
        'reg_app',
        'ulss',
        'tot_gg_ric',
      ];
      break;
    case 'ricovero':
      fields = [
        'cod_ric',
        'data_i',
        'data_f',
        'data_nasc',
        'motivo',
        'paziente',
      ];
      break;
    case 'diagnosi':
      fields = [
        'cod_dia',
        'data_dia',
        'cod_pat',
        'grav_pat',
        'medico',
        'paziente',
        'ricovero',
      ];
      break;
    default:
  }
  return fields;
}

module.exports = { convertEntitiesToSingular, getEntityKeys };
