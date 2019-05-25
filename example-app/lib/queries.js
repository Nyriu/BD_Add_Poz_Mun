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


/*

\subsubsection{Query 1}
Si vogliono ottenere tutti i farmaci che hanno causato effetti collaterali, ordinati in ordine decrescente per numero di effetti collaterali.
\begin{lstlisting}
SELECT t.farmaco, tc.effetti_collaterali
FROM (
  SELECT terapia, count(coll_dia) AS effetti_collaterali
  FROM terapia_prescritta 
  WHERE coll_dia IS NOT NULL
  GROUP BY terapia) tc
LEFT JOIN terapia t ON t.cod_ter = tc.terapia
ORDER BY effetti_collaterali DESC;
\end{lstlisting}

% this query doesn't work, lovely timeout
\subsubsection{Query 2}
Si vogliono ottenere tutte le coppie di pazienti in cui il primo paziente ha contratto le stesse malattie del secondo.
Si escludano le coppie che hanno avuto la stessa malattia nella stessa fascia d'età, considerando le due fasce d'età: sotto i 50 e sopra i 50.
\begin{lstlisting}
CREATE OR REPLACE VIEW patologie AS
SELECT p.cf, p.nome, p.cognome, p.data_nasc, d.cod_pat, d.data_dia, (d.data_dia - p.data_nasc)/365 as age
FROM paziente p
LEFT JOIN diagnosi d on p.cf = d.paziente;

CREATE INDEX idx_patologie ON diagnosi (paziente, cod_pat);

// timeout
SELECT *
FROM paziente p1, paziente p2
WHERE p1.cf <> p2.cf 
  AND NOT EXISTS (
    SELECT *
    FROM diagnosi d1
    WHERE d1.paziente = p1.cf 
      AND d1.cod_pat NOT IN (
        SELECT d2.cod_pat
        FROM diagnosi d2
        WHERE d2.paziente = p2.cf
      )
);


// per la modica tempistica di 5 minuti
explain analyze
SELECT p1.cf, p2.cf
FROM paziente p1, paziente p2
WHERE p1.cf <> p2.cf 
  AND (((date_part('year', age(p1.data_nasc)) - 50) * (date_part('year', age(p2.data_nasc)) - 50)) < 0)
  AND NOT EXISTS (
    SELECT d1.paziente, d1.cod_pat
    FROM diagnosi d1
    WHERE d1.paziente = p1.cf 
      AND NOT EXISTS (
        SELECT d2.paziente, d2.cod_pat
        FROM diagnosi d2
        WHERE d2.paziente = p2.cf
          AND d2.cod_pat = d1.cod_pat
      )
);

Hash Anti Join  (cost=4659.81..158324614.84 rows=17998200 width=34) (actual time=6898.189..574676.471 rows=22160 loops=1)
Hash Cond: ((p1.cf)::text = (d1.paziente)::text)
Join Filter: (NOT (SubPlan 1))
Rows Removed by Join Filter: 805088
->  Nested Loop  (cost=0.00..5500617.00 rows=33330000 width=34) (actual time=0.103..292916.041 rows=48779276 loops=1)
      Join Filter: (((p1.cf)::text <> (p2.cf)::text) AND (((date_part('year'::text, age((('now'::cstring)::date)::timestamp with time zone, (p1.data_nasc)::timestamp with time zone)) - '50'::double precision) * (date_part('year'::text, age((('now'::cstring)::date)::timestamp with time zone, (p2.data_nasc)::timestamp with time zone)) - '50'::double precision)) < '0'::double precision))
      Rows Removed by Join Filter: 51220724
      ->  Seq Scan on paziente p1  (cost=0.00..296.00 rows=10000 width=21) (actual time=0.016..7.360 rows=10000 loops=1)
      ->  Materialize  (cost=0.00..346.00 rows=10000 width=21) (actual time=0.000..0.752 rows=10000 loops=10000)
            ->  Seq Scan on paziente p2  (cost=0.00..296.00 rows=10000 width=21) (actual time=0.005..4.144 rows=10000 loops=1)
->  Hash  (cost=2454.25..2454.25 rows=120125 width=21) (actual time=91.112..91.112 rows=120125 loops=1)
      Buckets: 32768  Batches: 8  Memory Usage: 1025kB
      ->  Seq Scan on diagnosi d1  (cost=0.00..2454.25 rows=120125 width=21) (actual time=0.015..40.146 rows=120125 loops=1)
SubPlan 1
  ->  Index Only Scan using idx_patologie on diagnosi d2  (cost=0.42..8.44 rows=1 width=0) (actual time=0.005..0.005 rows=0 loops=49562204)
        Index Cond: ((paziente = (p2.cf)::text) AND (cod_pat = (d1.cod_pat)::text))
        Heap Fetches: 805088
Planning time: 1.002 ms
Execution time: 574679.350 ms


// un paio di minuti, ma è sbagliata credo
SELECT p1.cf, p2.cf
FROM paziente p1, paziente p2
WHERE p1.cf <> p2.cf 
  AND ((p1.data_nasc - p2.data_nasc) > (50 * 365))
  AND NOT EXISTS (
    SELECT d1.paziente, d1.cod_pat
    FROM diagnosi d1
    WHERE d1.paziente = p1.cf 
      AND NOT EXISTS (
        SELECT d2.paziente, d2.cod_pat
        FROM diagnosi d2
        WHERE d2.paziente = p2.cf
          AND d2.cod_pat = d1.cod_pat
      )
);


\end{lstlisting}

\subsubsection{Query 3}
Per ogni provincia il paziente con il maggior numero di diagnosi.
\begin{lstlisting}
CREATE OR REPLACE VIEW count_patologie AS
SELECT p.cf, p.nome, p.cognome, p.prov_res, count(d.cod_pat) as num_pat
FROM paziente p
LEFT JOIN diagnosi d on p.cf = d.paziente
GROUP BY p.cf;

// senza nomi
SELECT prov_res, max(num_pat)
FROM count_patologie
GROUP BY prov_res;

// chiaramente la soluzione ...
explain analyze SELECT *
FROM count_patologie cp1
INNER JOIN (
  SELECT cp2.prov_res, max(cp2.num_pat)
  FROM count_patologie cp2
  GROUP BY cp2.prov_res
) tmp 
  ON cp1.prov_res = tmp.prov_res
  AND cp1.num_pat = max
ORDER BY cp1.prov_res;

Sort  (cost=11263.93..11264.05 rows=50 width=59) (actual time=286.493..286.500 rows=144 loops=1)
   Sort Key: p.prov_res
   Sort Method: quicksort  Memory: 45kB
   ->  Hash Join  (cost=10512.02..11262.52 rows=50 width=59) (actual time=282.501..286.337 rows=144 loops=1)
         Hash Cond: (((p.prov_res)::text = (p_1.prov_res)::text) AND ((count(d.cod_pat)) = (max((count(d_1.cod_pat))))))
         ->  HashAggregate  (cost=5127.51..5227.51 rows=10000 width=44) (actual time=181.632..184.288 rows=10000 loops=1)
               Group Key: p.cf
               ->  Hash Right Join  (cost=421.00..4526.90 rows=120122 width=44) (actual time=7.965..119.793 rows=120125 loops=1)
                     Hash Cond: ((d.paziente)::text = (p.cf)::text)
                     ->  Seq Scan on diagnosi d  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.010..22.873 rows=120125 loops=1)
                     ->  Hash  (cost=296.00..296.00 rows=10000 width=40) (actual time=7.925..7.925 rows=10000 loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 849kB
                           ->  Seq Scan on paziente p  (cost=0.00..296.00 rows=10000 width=40) (actual time=0.012..3.791 rows=10000 loops=1)
         ->  Hash  (cost=5381.51..5381.51 rows=200 width=11) (actual time=100.781..100.781 rows=110 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 14kB
               ->  HashAggregate  (cost=5377.51..5379.51 rows=200 width=11) (actual time=100.738..100.753 rows=110 loops=1)
                     Group Key: p_1.prov_res
                     ->  HashAggregate  (cost=5127.51..5227.51 rows=10000 width=24) (actual time=96.160..98.325 rows=10000 loops=1)
                           Group Key: p_1.cf
                           ->  Hash Right Join  (cost=421.00..4526.90 rows=120122 width=24) (actual time=3.868..62.530 rows=120125 loops=1)
                                 Hash Cond: ((d_1.paziente)::text = (p_1.cf)::text)
                                 ->  Seq Scan on diagnosi d_1  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.004..12.808 rows=120125 loops=1)
                                 ->  Hash  (cost=296.00..296.00 rows=10000 width=20) (actual time=3.842..3.842 rows=10000 loops=1)
                                       Buckets: 16384  Batches: 1  Memory Usage: 636kB
                                       ->  Seq Scan on paziente p_1  (cost=0.00..296.00 rows=10000 width=20) (actual time=0.006..1.980 rows=10000 loops=1)
 Planning time: 0.928 ms
 Execution time: 286.738 ms

// this is faster cause I'm stupid
SELECT *
FROM count_patologie cp1
WHERE NOT EXISTS (
  SELECT *
  FROM count_patologie cp2
  WHERE cp1.prov_res = cp2.prov_res
  AND cp2.num_pat > cp1.num_pat
);

Hash Anti Join  (cost=10580.02..10951.89 rows=8333 width=48) (actual time=257.341..273.240 rows=144 loops=1)
   Hash Cond: ((p.prov_res)::text = (cp2.prov_res)::text)
   Join Filter: (cp2.num_pat > (count(d.cod_pat)))
   Rows Removed by Join Filter: 48759
   ->  HashAggregate  (cost=5127.51..5227.51 rows=10000 width=44) (actual time=155.647..158.476 rows=10000 loops=1)
         Group Key: p.cf
         ->  Hash Right Join  (cost=421.00..4526.90 rows=120122 width=44) (actual time=7.754..101.733 rows=120125 loops=1)
               Hash Cond: ((d.paziente)::text = (p.cf)::text)
               ->  Seq Scan on diagnosi d  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.007..18.525 rows=120125 loops=1)
               ->  Hash  (cost=296.00..296.00 rows=10000 width=40) (actual time=7.718..7.718 rows=10000 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 849kB
                     ->  Seq Scan on paziente p  (cost=0.00..296.00 rows=10000 width=40) (actual time=0.012..3.567 rows=10000 loops=1)
   ->  Hash  (cost=5327.51..5327.51 rows=10000 width=11) (actual time=101.452..101.452 rows=10000 loops=1)
         Buckets: 16384  Batches: 1  Memory Usage: 597kB
         ->  Subquery Scan on cp2  (cost=5127.51..5327.51 rows=10000 width=11) (actual time=96.567..99.866 rows=10000 loops=1)
               ->  HashAggregate  (cost=5127.51..5227.51 rows=10000 width=24) (actual time=96.566..98.738 rows=10000 loops=1)
                     Group Key: p_1.cf
                     ->  Hash Right Join  (cost=421.00..4526.90 rows=120122 width=24) (actual time=3.847..62.511 rows=120125 loops=1)
                           Hash Cond: ((d_1.paziente)::text = (p_1.cf)::text)
                           ->  Seq Scan on diagnosi d_1  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.004..12.660 rows=120125 loops=1)
                           ->  Hash  (cost=296.00..296.00 rows=10000 width=20) (actual time=3.820..3.820 rows=10000 loops=1)
                                 Buckets: 16384  Batches: 1  Memory Usage: 636kB
                                 ->  Seq Scan on paziente p_1  (cost=0.00..296.00 rows=10000 width=20) (actual time=0.006..2.067 rows=10000 loops=1)
 Planning time: 0.843 ms
 Execution time: 273.448 ms


\end{lstlisting}

\subsubsection{Query 4}
Si vogliono ottenere i pazienti che sono stati curati almeno due volte consecutivamente con lo stesso farmaco.
\begin{lstlisting}
CREATE OR REPLACE VIEW terapie_prescritte AS
SELECT *
FROM terapia_prescritta tp
LEFT JOIN diagnosi d ON tp.diagnosi = d.cod_dia
LEFT JOIN paziente p ON d.paziente = p.cf 
LEFT JOIN terapia t ON tp.terapia = t.cod_ter;

// inner join is fucking useless vedi sotto
SELECT 
  tp1.cf, tp1.data_i, tp1.diagnosi, tp1.terapia, tp1.farmaco
  , tp2.cf, tp2.data_i, tp2.diagnosi, tp2.terapia, tp2.farmaco
FROM terapie_prescritte tp1
INNER JOIN terapie_prescritte tp2
  ON tp1.paziente = tp2.paziente
  AND tp1.diagnosi <> tp2.diagnosi
  AND tp1.farmaco = tp2.farmaco
  AND tp1.data_i < tp2.data_i
AND NOT EXISTS (
  SELECT *
  FROM terapie_prescritte tp3
  WHERE tp3.cf = tp1.cf
  AND tp3.data_i > tp1.data_i
  AND tp3.data_i < tp2.data_i
);  

Hash Anti Join  (cost=32733.01..61391.65 rows=465 width=74) (actual time=565.452..823.643 rows=103 loops=1)
Hash Cond: ((p.cf)::text = (p_2.cf)::text)
Join Filter: ((tp_2.data_i > tp.data_i) AND (tp_2.data_i < tp_1.data_i))
Rows Removed by Join Filter: 3532
->  Nested Loop Left Join  (cost=18527.75..46487.91 rows=523 width=74) (actual time=350.973..596.234 rows=790 loops=1)
      ->  Nested Loop Left Join  (cost=18527.46..46320.46 rows=523 width=74) (actual time=350.957..592.819 rows=790 loops=1)
            ->  Hash Join  (cost=18527.18..46153.02 rows=523 width=74) (actual time=350.923..587.059 rows=790 loops=1)
                  Hash Cond: (((d.paziente)::text = (d_1.paziente)::text) AND ((t.farmaco)::text = (t_1.farmaco)::text))
                  Join Filter: (((tp.diagnosi)::integer <> (tp_1.diagnosi)::integer) AND (tp.data_i < tp_1.data_i))
                  Rows Removed by Join Filter: 116040
                  ->  Hash Join  (cost=4142.40..11755.12 rows=115244 width=37) (actual time=75.979..211.033 rows=115244 loops=1)
                        Hash Cond: ((tp.terapia)::integer = (t.cod_ter)::integer)
                        ->  Hash Join  (cost=4054.99..10083.11 rows=115244 width=29) (actual time=74.400..171.582 rows=115244 loops=1)
                              Hash Cond: ((d.cod_dia)::integer = (tp.diagnosi)::integer)
                              ->  Seq Scan on diagnosi d  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.006..22.163 rows=120125 loops=1)
                              ->  Hash  (cost=2051.44..2051.44 rows=115244 width=12) (actual time=74.286..74.286 rows=115244 loops=1)
                                    Buckets: 32768  Batches: 4  Memory Usage: 1501kB
                                    ->  Seq Scan on terapia_prescritta tp  (cost=0.00..2051.44 rows=115244 width=12) (actual time=0.008..34.202 rows=115244 loops=1)
                        ->  Hash  (cost=51.07..51.07 rows=2907 width=12) (actual time=1.566..1.566 rows=2907 loops=1)
                              Buckets: 4096  Batches: 1  Memory Usage: 163kB
                              ->  Seq Scan on terapia t  (cost=0.00..51.07 rows=2907 width=12) (actual time=0.011..0.775 rows=2907 loops=1)
                  ->  Hash  (cost=11755.12..11755.12 rows=115244 width=37) (actual time=271.895..271.895 rows=115244 loops=1)
                        Buckets: 32768  Batches: 8  Memory Usage: 1234kB
                        ->  Hash Join  (cost=4142.40..11755.12 rows=115244 width=37) (actual time=77.909..229.003 rows=115244 loops=1)
                              Hash Cond: ((tp_1.terapia)::integer = (t_1.cod_ter)::integer)
                              ->  Hash Join  (cost=4054.99..10083.11 rows=115244 width=29) (actual time=76.338..186.449 rows=115244 loops=1)
                                    Hash Cond: ((d_1.cod_dia)::integer = (tp_1.diagnosi)::integer)
                                    ->  Seq Scan on diagnosi d_1  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.006..28.874 rows=120125 loops=1)
                                    ->  Hash  (cost=2051.44..2051.44 rows=115244 width=12) (actual time=76.227..76.227 rows=115244 loops=1)
                                          Buckets: 32768  Batches: 4  Memory Usage: 1501kB
                                          ->  Seq Scan on terapia_prescritta tp_1  (cost=0.00..2051.44 rows=115244 width=12) (actual time=0.008..34.486 rows=115244 loops=1)
                              ->  Hash  (cost=51.07..51.07 rows=2907 width=12) (actual time=1.560..1.560 rows=2907 loops=1)
                                    Buckets: 4096  Batches: 1  Memory Usage: 163kB
                                    ->  Seq Scan on terapia t_1  (cost=0.00..51.07 rows=2907 width=12) (actual time=0.010..0.773 rows=2907 loops=1)
            ->  Index Only Scan using paziente_pkey on paziente p  (cost=0.29..0.31 rows=1 width=17) (actual time=0.006..0.006 rows=1 loops=790)
                  Index Cond: (cf = (d.paziente)::text)
                  Heap Fetches: 647
      ->  Index Only Scan using paziente_pkey on paziente p_1  (cost=0.29..0.31 rows=1 width=17) (actual time=0.003..0.004 rows=1 loops=790)
            Index Cond: (cf = (d_1.paziente)::text)
            Heap Fetches: 647
->  Hash  (cost=12088.71..12088.71 rows=115244 width=21) (actual time=214.280..214.280 rows=115244 loops=1)
      Buckets: 32768  Batches: 8  Memory Usage: 993kB
      ->  Hash Join  (cost=4475.99..12088.71 rows=115244 width=21) (actual time=47.113..185.471 rows=115244 loops=1)
            Hash Cond: ((d_2.paziente)::text = (p_2.cf)::text)
            ->  Hash Join  (cost=4054.99..10083.11 rows=115244 width=21) (actual time=42.927..139.187 rows=115244 loops=1)
                  Hash Cond: ((d_2.cod_dia)::integer = (tp_2.diagnosi)::integer)
                  ->  Seq Scan on diagnosi d_2  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.005..22.258 rows=120125 loops=1)
                  ->  Hash  (cost=2051.44..2051.44 rows=115244 width=12) (actual time=42.679..42.679 rows=115244 loops=1)
                        Buckets: 32768  Batches: 4  Memory Usage: 1501kB
                        ->  Seq Scan on terapia_prescritta tp_2  (cost=0.00..2051.44 rows=115244 width=12) (actual time=0.008..19.618 rows=115244 loops=1)
            ->  Hash  (cost=296.00..296.00 rows=10000 width=17) (actual time=4.084..4.084 rows=10000 loops=1)
                  Buckets: 16384  Batches: 1  Memory Usage: 607kB
                  ->  Seq Scan on paziente p_2  (cost=0.00..296.00 rows=10000 width=17) (actual time=0.007..1.783 rows=10000 loops=1)
                  Planning time: 9.354 ms
                  Execution time: 823.884 ms
                 
// this is faster
SELECT 
  tp1.cf, tp1.data_i, tp1.diagnosi, tp1.terapia, tp1.farmaco
FROM terapie_prescritte tp1
WHERE EXISTS (
  SELECT *
  FROM terapie_prescritte tp2
  WHERE tp1.paziente = tp2.paziente
  AND tp1.diagnosi <> tp2.diagnosi
  AND tp1.farmaco = tp2.farmaco
  AND tp1.data_i < tp2.data_i
  AND NOT EXISTS (
    SELECT *
    FROM terapie_prescritte tp3
    WHERE tp3.cf = tp1.cf
    AND tp3.data_i > tp1.data_i
    AND tp3.data_i < tp2.data_i
  )
);

Hash Semi Join  (cost=18948.18..31903.54 rows=1 width=37) (actual time=349.927..5732.492 rows=103 loops=1)
   Hash Cond: (((d.paziente)::text = (d_1.paziente)::text) AND ((t.farmaco)::text = (t_1.farmaco)::text))
   Join Filter: (((tp.diagnosi)::integer <> (tp_1.diagnosi)::integer) AND (tp.data_i < tp_1.data_i) AND (NOT (SubPlan 1)))
   Rows Removed by Join Filter: 116685
   ->  Hash Join  (cost=4563.40..13760.72 rows=115244 width=54) (actual time=83.909..277.310 rows=115244 loops=1)
         Hash Cond: ((tp.terapia)::integer = (t.cod_ter)::integer)
         ->  Hash Left Join  (cost=4475.99..12088.71 rows=115244 width=46) (actual time=82.265..236.162 rows=115244 loops=1)
               Hash Cond: ((d.paziente)::text = (p.cf)::text)
               ->  Hash Join  (cost=4054.99..10083.11 rows=115244 width=29) (actual time=76.085..182.098 rows=115244 loops=1)
                     Hash Cond: ((d.cod_dia)::integer = (tp.diagnosi)::integer)
                     ->  Seq Scan on diagnosi d  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.005..22.053 rows=120125 loops=1)
                     ->  Hash  (cost=2051.44..2051.44 rows=115244 width=12) (actual time=75.967..75.967 rows=115244 loops=1)
                           Buckets: 32768  Batches: 4  Memory Usage: 1501kB
                           ->  Seq Scan on terapia_prescritta tp  (cost=0.00..2051.44 rows=115244 width=12) (actual time=0.008..34.845 rows=115244 loops=1)
               ->  Hash  (cost=296.00..296.00 rows=10000 width=17) (actual time=6.136..6.136 rows=10000 loops=1)
                     Buckets: 16384  Batches: 1  Memory Usage: 607kB
                     ->  Seq Scan on paziente p  (cost=0.00..296.00 rows=10000 width=17) (actual time=0.015..2.850 rows=10000 loops=1)
         ->  Hash  (cost=51.07..51.07 rows=2907 width=12) (actual time=1.631..1.631 rows=2907 loops=1)
               Buckets: 4096  Batches: 1  Memory Usage: 163kB
               ->  Seq Scan on terapia t  (cost=0.00..51.07 rows=2907 width=12) (actual time=0.012..0.804 rows=2907 loops=1)
   ->  Hash  (cost=11755.12..11755.12 rows=115244 width=33) (actual time=240.900..240.900 rows=115244 loops=1)
         Buckets: 32768  Batches: 8  Memory Usage: 1178kB
         ->  Hash Join  (cost=4142.40..11755.12 rows=115244 width=33) (actual time=67.902..201.648 rows=115244 loops=1)
               Hash Cond: ((tp_1.terapia)::integer = (t_1.cod_ter)::integer)
               ->  Hash Join  (cost=4054.99..10083.11 rows=115244 width=29) (actual time=66.265..162.128 rows=115244 loops=1)
                     Hash Cond: ((d_1.cod_dia)::integer = (tp_1.diagnosi)::integer)
                     ->  Seq Scan on diagnosi d_1  (cost=0.00..2454.22 rows=120122 width=21) (actual time=0.006..23.079 rows=120125 loops=1)
                     ->  Hash  (cost=2051.44..2051.44 rows=115244 width=12) (actual time=66.161..66.161 rows=115244 loops=1)
                           Buckets: 32768  Batches: 4  Memory Usage: 1501kB
                           ->  Seq Scan on terapia_prescritta tp_1  (cost=0.00..2051.44 rows=115244 width=12) (actual time=0.008..30.551 rows=115244 loops=1)
               ->  Hash  (cost=51.07..51.07 rows=2907 width=12) (actual time=1.624..1.624 rows=2907 loops=1)
                     Buckets: 4096  Batches: 1  Memory Usage: 159kB
                     ->  Seq Scan on terapia t_1  (cost=0.00..51.07 rows=2907 width=12) (actual time=0.011..0.817 rows=2907 loops=1)
   SubPlan 1
     ->  Nested Loop  (cost=0.70..2872.69 rows=1 width=0) (actual time=6.446..6.446 rows=1 loops=790)
           ->  Nested Loop  (cost=0.42..2864.38 rows=1 width=17) (actual time=6.438..6.438 rows=1 loops=790)
                 ->  Seq Scan on diagnosi d_2  (cost=0.00..2754.53 rows=13 width=21) (actual time=1.214..6.405 rows=5 loops=790)
                       Filter: ((paziente)::text = (p.cf)::text)
                       Rows Removed by Filter: 36627
                 ->  Index Scan using terapia_prescritta_diagnosi_key on terapia_prescritta tp_2  (cost=0.42..8.44 rows=1 width=8) (actual time=0.005..0.005 rows=0 loops=4290)
                       Index Cond: ((diagnosi)::integer = (d_2.cod_dia)::integer)
                       Filter: ((data_i > tp.data_i) AND (data_i < tp_1.data_i))
                       Rows Removed by Filter: 1
           ->  Index Only Scan using paziente_pkey on paziente p_1  (cost=0.29..8.30 rows=1 width=17) (actual time=0.007..0.007 rows=1 loops=687)
                 Index Cond: (cf = (p.cf)::text)
                 Heap Fetches: 565
 Planning time: 3.092 ms
 Execution time: 5732.716 ms

 
\end{lstlisting}

%  more or less, manca un >= 
\subsubsection{Query 5}
Si vuole trovare il mese con il massimo numero di ricoveri.
Utilizzare una vista. 
%  l'esempio di vista che si intendeva qui è stato utilizzato nella 3 credo
\begin{lstlisting}
  CREATE OR REPLACE VIEW months_list AS SELECT GENERATE_SERIES( '2008-01-01'::date, now()::date, '1 month' ) as month;

  SELECT month, count(*)
  FROM months_list
  LEFT JOIN ricovero
  ON data_i < month::date 
  AND data_f > month::date
  GROUP BY month
  ORDER BY count DESC
  LIMIT 1;

\end{lstlisting}


\subsubsection{Query 6}
Utilizzando una vista, trovare il giorno con il massimo numero di persone ricoverate.
%  questa è uguale a quella sopra ma per giorni invece che per mesi
\begin{lstlisting}
  CREATE OR REPLACE VIEW days_list AS SELECT GENERATE_SERIES( '2008-01-01'::date, now()::date, '1 day' ) as day;

\end{lstlisting}
*/