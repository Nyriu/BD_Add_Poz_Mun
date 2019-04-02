-- TODO per comodita ci conviene abbreviare tutto prov_res, reg_app, tot_gg_ric...
--      senno' query lunghe come la fame

drop schema ospedale cascade;

create schema ospedale;
set search_path to ospedale;

create table paziente (
    cf varchar(16) primary key,
    cognome varchar not null,
    nome varchar not null,
    data_di_nascita date not null,
    luogo_di_nascita varchar not null,
    provincia_di_residenza varchar(2) not null,
    regione_di_appartenenza varchar,
    ulss varchar,
    totale_giorni_ricovero int -- valore da aggiornare tramite trigger quando
                               -- viene inserita data_fine in un nuovo ricovero
);

create table ricovero (
    codice_ricovero varchar(20) primary key, --provvisorio 20
    data_inizio date,
    data_fine date,
    motivo varchar,
    divisione_ospedaliera varchar
);

create table diagnosi (
    codice_diagnosi varchar(20) primary key,
    data_diagnosi timestamp,
    codice_patologia varchar(20),
    gravita_patologia boolean,
    medico varchar(16)
);

create table terapia (
    codice_terapia varchar(20) primary key,
    dose_giornaliera int,
    modalita_somministrazione varchar
);

create table terapia_prescritta (
    data_inizio date,
    data_fine date,
    medico_prescrivente varchar(16),
    codice_diagnosi varchar(20) references diagnosi, 
    codice_terapia varchar(20) references terapia,
    primary key (codice_diagnosi, codice_terapia)
);

create table farmaco (
    nome_commerciale varchar primary key,
    azienda_produttrice varchar,
    dose_giornaliera_raccomandata int
);

create table principio_attivo (
    nome varchar primary key
);

create table contiene (
    farmaco varchar references farmaco,
    principio_attivo varchar references principio_attivo,
    quantità int
);





-- ESEMPI ------------------------------------------------------------
-- ESEMPI ------------------------------------------------------------
-- ESEMPI ------------------------------------------------------------

-----------------------------------------------------------------------
-- ESEMPIO DOMAIN --
-----------------------------------------------------------------------
-- create domain cod_ricovero as varchar
--   TODO check RES12312
--   deve essere 'RES' seguito da numero

create domain dom_cod_prodotto as integer
  check (value > 0);


-----------------------------------------------------------------------
-- ESEMPIO INSERT --
-----------------------------------------------------------------------
insert into paziente(cf, nome, cognome, data_di_nascita, luogo_di_nascita, provincia_di_residenza, regione_di_appartenenza)
  values
    ('CF13123', 'Rossi', 'Luigino' , '2000-02-2', 'EH', 'EH', 'Feudo di Falkreath'), 
    ('CF86923', 'Rossi', 'Marietto', '2000-02-2', 'EH', 'EH', 'Feudo di Falkreath')
;


-----------------------------------------------------------------------
-- ESEMPIO FUNCTION --
-----------------------------------------------------------------------
create or replace function
num_liked()
returns table (id int, num_liked int)
language plpgsql as $$
 begin
  return query (
    select s.id::integer, count(id1)::integer
    from student s
      left join likes on s.id=id2
      group by s.id

  );
 end;
$$;

create or replace function
num_persone_a_cui_piace(in_id int, out num int)
language plpgsql as $$
 begin
  select count(*) into num
  from likes
  where likes.id2=in_id;
 end;
$$;


-----------------------------------------------------------------------
-- ESEMPIO CONSTRAIN --
-----------------------------------------------------------------------
create or replace function
check_recensione_unica(in_rid int)
returns bool
language plpgsql as $$ 
 begin
  perform *
  from rating rat1
  where exists ( select *
                 from rating rat2
                 where rat1.rid=rat2.rid
                   and rat1.mid=rat2.mid
                   and rat1.stars<>rat2.stars
                   );
  return not found;
 end;
$$;

alter table rating add
constraint check_recensione_unica_per_film
check(recensione_unica(rid,mid));

-----------------------------------------------------------------------
-- ESEMPIO TRIGGER --
-----------------------------------------------------------------------
create or replace function valida_libro()
returns trigger as
$$
  declare
    dummy dom_cod_prodotto; -- Variabile non usata
  begin
    -- Non si può usare 'select' senza 'into' se si vuole ignorare il risultato
    -- Altrimenti, è possibile utilizzare 'perform' (vedi procedura valida_dvd)
    select id into dummy from DVD where id = new.id;
    if found
    then
      raise exception 'Specializzazione non esclusiva';
      return null;
    else
      return new;
    end if;
  end;
$$ language plpgsql;

create trigger libro_esclusivo before insert or update
  on Libro for each row execute procedure valida_libro();

create or replace function valida_dvd()
returns trigger as
$$
  begin
  -- 'perform' è equivalente a 'select', ma permette di ignorare il risultato
  -- (si può usare solo  all'interno di funzioni).
  -- "A PERFORM statement sets FOUND true if it produces (and discards) one or more rows, false if no row is produced." (§40.5.5)
    perform * from Libro where id = new.id;
    if found
    then
      raise exception 'Specializzazione non esclusiva';
      return null;
    else
      return new;
    end if;
  end;
$$ language plpgsql;

create trigger dvd_esclusivo before insert or update
  on DVD for each row execute procedure valida_dvd();
