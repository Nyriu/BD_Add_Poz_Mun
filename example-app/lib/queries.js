const pool = require('../lib/dbAuth');


function queryErrorHandler(error) {
  // pff there aren't errors in our queries
}

const queries = {

  async selectEntities(options) {
    try {
      const { entity } = options;
      const { rows } = await pool.query(
        /*
        SELECT *
        FROM ospedale.paziente
        */
        `SELECT *
        FROM ospedale.${entity}`,
      );
      return rows;
    } catch (err) {
      queryErrorHandler(err);
    }
  },

  async selectEntity(options) {
    try {
      const { entity, key, id } = options;
      const { rows } = await pool.query(
        /*
        SELECT *
        FROM ospedale.paziente
        WHERE cd = 'AAA...'
        */
        `SELECT *
        FROM ospedale.${entity}
        WHERE ${key} = ${id}`,
      );
      return rows;
    } catch (err) {
      queryErrorHandler(err);
    }
  },

  // TOO Uff ...
  /*
  - genrico è comodo per scrivere poco,
  - nel dettaglio meno errori e meno informazioni richieste al controller
  */
  async insertEntity() {
    try {
      const { entity, columns, values } = options;
      const { rows } = await pool.query(
        /*
        SELECT *
        FROM ospedale.paziente
        WHERE cd = 'AAA...'
        */
        `INSERT INTO ospedale.${entity}
        WHERE ${key} = ${id}`,
      );
      return rows;
    } catch (err) {
      queryErrorHandler(err);
    }
  },

  async updatePaziente() {

  },

  async deletePaziente() {

  },


  /*
  filtri di entità per entità padre

  es. ricoveri del paziente

  SELECT *
  FROM ospedale.ricovero ricovero
  LEFT JOIN ospedale.paziente paziente on ricovero.paziente = paziente.cf
  WHERE paziente.nome = '...' and paziente.cognome = '...'

  es. terapie del paziente

  SELECT *
  FROM ospedale.terapie_prescritte tp
  LEFT JOIN ospedale.ricovero r on tp.ricovero = r.cod_ric
  LEFT JOIN ospedale.paziente p on r.paziente = p.cf
  WHERE p.nome = '...' and p.cognome = '...'

  una dozzina di queste ...

  es. terapie più utilizzate

  SELECT t.? COUNT(*)
  FROM ospedale.terapie t
  LEFT JOIN ospedale.terapia_prescritta tp on t.? = tp.?
  GROUP BY t.?
  ORDER BY COUNT(*) DESC

  si può usare anche su numero di ricoveri o diagnosi di un paziente,
  per calcolare a che diagnosi è arrivato il paziente

  es. paziente recidivi :)

  SELECT *
  FROM ospedale.paziente p
  WHERE EXISTS (
    SELECT COUNT(*)
    FROM ospedale.ricovero r
    LEFT JOIN ospedale.paziente p on r.paziente = p.cf
    WHERE p.nome = '...' and p.cognome = '...'
    GROUP BY p.cf
    HAVING COUNT (*) > 1
  )
  ORDER BY p.nome, p.cognome


      Le coppie A e B di paziente tali che B è sempre stato ricoverato quando A era ricoverato

      SELECT a.cf as a_cf, b.cf as b_cf
FROM paziente as a
INNER JOIN paziente
	as b on a.nome = b.nome 
	and a.cf <> b.cf
WHERE EXISTS (
	SELECT r.cod_ric
	FROM ricovero as r
	WHERE r.paziente = a.cf
	and EXISTS(
		SELECT r2.cod_ric
		FROM ricovero as r2
		WHERE r2.paziente = b.cf
		and r2.data_i > r.data_i
		and r2.data_f < r.data_f
	)
)
ORDER BY a_cf;

SET search_path TO 'ospedale';

SELECT ra.cod_ric, ra.paziente as ra_cf, rb.paziente as rb_cf
FROM ricovero as ra, ricovero as rb
WHERE ra.paziente = 'DIDROS02K43Z948X'
	and ra.data_i < rb.data_i
	and ra.data_f > rb.data_f;

  */

};

module.exports = queries;
