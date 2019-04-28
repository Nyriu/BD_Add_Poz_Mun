-- set search_path to ospedale;
-- 
-- drop table diagnosi;
-- drop domain icd10;
-- drop domain dom_dia;
-- 
-- create domain ICD10 as varchar
--     check ( value ~ ('^[A-Z]([A-Z]|[0-9]){2}((\.)([0-9])*)?$'));
-- 
-- create domain dom_dia as varchar
--     check ( value ~ ('DIA' || '[0-9]+'));
-- 
-- 
-- create table diagnosi (
--     cod_dia dom_dia primary key,
--     cod_pat ICD10
-- );
-- 
-- insert into diagnosi(cod_dia, cod_pat)
--     values
--     ('DIA1','T90'),
--     ('DIA100','C34.3435'),
-- 	('DIA250','CAA4.3435.366');
-- 
-- select cod_dia, cod_pat from diagnosi;
-- 
-- 
-- ---------------------------------------------------
-- -- TESTING su ricalcolo_gg
-- ---------------------------------------------------
-- 
-- insert into paziente(cf,cognome, nome, data_nasc, luogo_nasc, prov_res) values
--   ('ABCDEF01A01A012A', 'Belli', 'Armando', '2000-01-01', 'Abbabba', 'AB')
--   ;
-- 
-- insert into ricovero(cod_ric, data_i, motivo, div_osp, paziente) values
--   ('RIC001', '2000-01-01', 'a', 'd', 'ABCDEF01A01A012A'),
--   ('RIC002', '2000-02-01', 'a', 'd', 'ABCDEF01A01A012A'),
--   ('RIC003', '2000-03-01', 'a', 'd', 'ABCDEF01A01A012A')
--   ;
-- 
-- 
-- update ricovero SET data_f = '2000-01-11' where cod_ric = 'RIC001';
-- update ricovero SET data_f = '2000-02-11' where cod_ric = 'RIC002';
-- 
-- 
-- -- update per tutti i pazienti
-- update paziente SET tot_gg_ric = ricalcolo_gg(cf);
-- 
-- 
-- ---------------------------------------------------
-- -- TESTING TRIGGERS su tot_gg_ric
-- ---------------------------------------------------
-- 
-- 
-- set search_path to ospedale;
-- insert into paziente(cf,cognome, nome, data_nasc, luogo_nasc, prov_res) values
--   ('ABCDEF01A01A012A', 'Belli', 'Armando', '2000-01-01', 'Abbabba', 'AB'),
--   ('ABCDEF01A01A012B', 'Celli', 'Armando', '2000-01-01', 'Abbabba', 'AB')
--   ;
-- 
-- select cf, tot_gg_ric from paziente;
-- 
-- insert into ricovero(cod_ric, data_i, data_f, motivo, div_osp, paziente) values
--   ('RIC001', '2000-01-05', '2000-01-10', 'a', 'd', 'ABCDEF01A01A012A'),
--   ('RIC002', '2000-01-01', '2000-01-21', 'a', 'd', 'ABCDEF01A01A012B')
--   ;
-- 
-- select cf, tot_gg_ric from paziente; -- si aggiorna
-- 
-- insert into ricovero(cod_ric, data_i, motivo, div_osp, paziente) values
--   ('RIC003', '2000-02-01', 'a', 'd', 'ABCDEF01A01A012A'),
--   ('RIC004', '2000-02-01', 'a', 'd', 'ABCDEF01A01A012B')
--   ;
-- 
-- select cf, tot_gg_ric from paziente; -- rimane uguale 
-- 
-- update ricovero set data_i = '2000-01-01' where cod_ric = 'RIC001';
-- update ricovero set data_f = '2000-02-26' where cod_ric = 'RIC004';
-- 
-- select cf, tot_gg_ric from paziente; -- si aggiorna


---------------------------------------------------
-- TESTING CONSTRAIN su data_i e data_f
---------------------------------------------------

set search_path to ospedale;
insert into paziente(cf,cognome, nome, data_nasc, luogo_nasc, prov_res) values
  ('ABCDEF01A01A012A', 'Belli', 'Armando', '2000-01-01', 'Abbabba', 'AB'),
  ('ABCDEF01A01A012B', 'Celli', 'Armando', '2000-01-01', 'Abbabba', 'AB')
  ;

insert into ricovero(data_i, data_f, motivo, div_osp, paziente) values
  ('2000-01-05', '2000-01-10', 'a', 'd', 'ABCDEF01A01A012A'),
  ('2000-01-01', '2000-01-21', 'a', 'd', 'ABCDEF01A01A012B')
  ;

insert into ricovero(data_i, motivo, div_osp, paziente) values
  ('2000-02-01', 'a', 'd', 'ABCDEF01A01A012A'),
  ('2000-02-01', 'a', 'd', 'ABCDEF01A01A012B')
  ;

update ricovero set data_i = '2000-01-01' where cod_ric = 'RIC001';
update ricovero set data_f = '2000-02-26' where cod_ric = 'RIC004';

-- update ricovero set data_f = '2000-01-26' where cod_ric = 'RIC003'; -- deve fallire
-- update ricovero set data_f = '1999-02-26' where cod_ric = 'RIC003'; -- deve fallire
-- update ricovero set data_i = '2000-03-01' where cod_ric = 'RIC001'; -- deve fallire
-- select * from paziente;
select * from ricovero;
select * from diagnosi;

-- testing su terapia prescritta TODO completare
insert into farmaco (azienda_prod, dose_gg_racc, nome_comm) values
  ('ciccio',1,'AAA')
  ;
-- testing su data diagnosi
insert into diagnosi (cod_dia, data_dia, cod_pat, grav_pat, medico, ricovero) values
  ('DIA01', '2000-03-01', 'T10.103040', 'true', 'Gigio', 'RIC003'), -- stesso giorno di inizio ricvero (ric senza fine)
  ('DIA02', '2000-01-05', 'T10.103040', 'true', 'Gigio', 'RIC001')  -- stesso giorno di inizio ricvero (ric con fine)
  ;
update diagnosi set data_dia = '2000-03-02' where cod_dia = 'DIA01'; -- okay (ric senza fine)
update diagnosi set data_dia = '2000-01-08' where cod_dia = 'DIA02'; -- okay

select * from diagnosi;

update diagnosi set paziente = 'ABCDEF01A01A012B' where cod_dia = 'DIA02';

select * from diagnosi;

  -- devono fallire
-- insert into diagnosi (cod_dia, data_dia, cod_pat, grav_pat, medico, ricovero) values
--   ('DIA03', '2000-02-01', 'T10.103040', 'true', 'Gigio', 'RIC003'); -- prima di data_i(ric senza fine)
-- insert into diagnosi (cod_dia, data_dia, cod_pat, grav_pat, medico, ricovero) values
--   ('DIA04', '2000-05-01', 'T10.103040', 'true', 'Gigio', 'RIC001'); -- dopo data_f
-- 
-- update diagnosi set data_dia = '1999-03-02' where cod_dia = 'DIA01'; -- fallire (ric senza fine)
-- update diagnosi set data_dia = '2000-01-18' where cod_dia = 'DIA02'; -- fallire

-- testing su terapia prescritta TODO completare

-- -- testing su terapia prescritta TODO completare
-- insert into farmaco (azienda_prod, dose_gg_racc, nome_comm) values
--   ('ciccio',1,'AAA')
--   ;


---------------------------------------------------
-- TESTING CONSTRAIN su T_P dia ed coll_dia
---------------------------------------------------

-- TODO


---------------------------------------------------
-- TESTING TRIGGERS su farmaco alemno un pr_att
--------------------------------------------------

-- TODO
