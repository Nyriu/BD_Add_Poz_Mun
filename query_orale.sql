-- ELENCO DI QUERY PER ESAME ORALE

-- Query 1 -OK
CREATE OR REPLACE VIEW COUNT_DIA AS
SELECT cf, nome, cognome, prov_res,
       count(cod_dia) AS num_dia
FROM PAZIENTE
  JOIN DIAGNOSI ON paziente = cf
GROUP BY cf;

SELECT *
FROM COUNT_DIA cd1
WHERE
  NOT EXISTS
  (SELECT *
   FROM COUNT_DIA cd2
   WHERE cd2.prov_res = cd1.prov_res
     AND cd2.num_dia > cd1.num_dia);




-- Query 2
SELECT p.cf, p.nome, p.cognome
FROM PAZIENTE p
WHERE
  EXISTS
  (SELECT *
   FROM RICOVERO r1
   JOIN RICOVERO r2 ON
     r1.cod_ric < r2.cod_ric AND
     r1.paziente = r2.paziente 
   WHERE r1.paziente = p.cf
     AND
     NOT EXISTS
     (SELECT *
      FROM RICOVERO r3
      WHERE r3.paziente = r1.paziente AND
            r3.cod_ric <> r1.cod_ric AND
            r3.cod_ric <> r2.cod_ric));




-- Query 3
CREATE OR REPLACE VIEW MONTH_COUNT AS
SELECT month, COUNT(*) AS c
FROM (SELECT cod_ric,
             date_part('month', data_i) AS month
      FROM RICOVERO) AS ric_month
GROUP BY month;

SELECT month, c
FROM MONTH_COUNT mc
WHERE
  NOT EXISTS
  (SELECT *
   FROM MONTH_COUNT
   WHERE mc.c < c);



-- Query 4

SELECT farmaco, tc.n 
FROM
  (SELECT terapia, COUNT(*) AS n
   FROM TERAPIA_PRESCRITTA
   WHERE coll_dia IS NOT NULL
   GROUP BY terapia) AS tc
  JOIN TERAPIA ON cod_ter = tc.terapia
ORDER BY tc.n DESC;





-- Query 5
CREATE OR REPLACE VIEW PAZ_TER AS
SELECT cf, nome, cognome, cod_ter, data_i, farmaco
FROM PAZIENTE
  JOIN DIAGNOSI ON paziente = cf
  JOIN TERAPIA_PRESCRITTA ON coll_dia = cod_dia
  JOIN TERAPIA ON cod_ter = terapia;

SELECT DISTINCT pt1.cf, pt1.nome,
                pt1.cognome, pt1.farmaco
FROM PAZ_TER pt1
WHERE
  EXISTS
  (SELECT *
   FROM PAZ_TER pt2
   WHERE pt2.cf = pt1.cf
     AND pt2.cod_ter = pt1.cod_ter
     AND pt2.farmaco = pt1.farmaco
     AND
     NOT EXISTS
     (SELECT *
      FROM PAZ_TER pt3
      WHERE pt3.cf = pt1.cf
        AND pt1.data_i < pt3.data_i
        AND pt3.data_i < pt2.data_i
        AND pt3.farmaco <> pt1.farmaco
        ));




-- Query 6
SELECT p1.cf, p2.cf
FROM PAZIENTE p1
  JOIN PAZIENTE p2 ON p1.cf < p2.cf
WHERE
  NOT EXISTS
  (SELECT *
   FROM DIAGNOSI pat2
   WHERE pat2.paziente = p2.cf
     AND
     NOT EXISTS
     (SELECT *
      FROM DIAGNOSI pat1
      WHERE pat1.paziente = p1.cf
        AND pat1.cod_pat = pat2.cod_pat))
  AND
  NOT EXISTS
  (SELECT *
   FROM DIAGNOSI pat1
   WHERE pat1.paziente = p1.cf
     AND
     NOT EXISTS
     (SELECT *
      FROM DIAGNOSI pat2
      WHERE pat2.paziente = p2.cf
        AND pat2.cod_pat = pat1.cod_pat));



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- ELSMAG30M48J782P
-- FORGUM05T37M534L

-- Trigger sulle date 
insert into ricovero(data_i, motivo, div_osp, paziente) values ('2018-03-01', 'a', 'd', 'ELSMAG30M48J782P');


insert into ricovero(data_i, data_f, motivo, div_osp, paziente) values ('2018-03-01', '2018-03-05', 'a', 'd', 'FORGUM05T37M534L');

-- Query problematica !!
insert into ricovero(data_i, motivo, div_osp, paziente) values ('2018-03-01', 'a', 'd', 'FORGUM05T37M534L');
-- END -- Query problematica !!


insert into diagnosi (cod_dia, data_dia, cod_pat, grav_pat, medico, ricovero) values
  ('DIA01', '2000-03-01', 'T10.103040', 'true', 'Gigio', 'RIC003'), -- stesso giorno di inizio ricvero (ric senza fine)
  ('DIA02', '2000-01-05', 'T10.103040', 'true', 'Gigio', 'RIC001')  -- stesso giorno di inizio ricvero (ric con fine)
  ;
