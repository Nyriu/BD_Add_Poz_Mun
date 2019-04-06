set search_path to ospedale;

drop table terapia_prescritta;
drop table terapia;
drop table diagnosi;
drop table contiene;
drop table farmaco;
drop table principio_attivo;
drop table ricovero;
drop table paziente;

drop domain dom_cf;
drop domain dom_dia;
drop domain dom_ric;
drop domain dom_ter;
drop domain ICD10;

drop schema ospedale;

----------------------------------------------------------------
-- COPIARE DA QUI IN POI PER CREARE LE TABELLE LA PRIMA VOLTA --
----------------------------------------------------------------

create schema ospedale;
set search_path to ospedale;

create domain dom_cf as varchar
    check ( value ~ '^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$' ); -- es MRARSS80A01F205W
    
create domain dom_ric as varchar
    check ( value ~ ('RIC' || '[0-9]+')); 

create domain dom_dia as varchar
    check ( value ~ ('DIA' || '[0-9]+')); 

create domain dom_ter as varchar
    check ( value ~ ('TER' || '[0-9]+')); 

create domain ICD10 as varchar
    check ( value ~ ('^[A-Z]([A-Z]|[0-9]){2}((\.)([0-9])*)?$')); 

create table paziente (
    cf dom_cf primary key,
    cognome varchar not null,
    nome varchar not null,
    data_nasc date not null,
    luogo_nasc varchar not null,
    prov_res varchar(2) not null,
    reg_app varchar,
    ulss varchar,
    tot_gg_ric int default 0               
);

create table ricovero (
    cod_ric dom_ric primary key, 
    data_i date not null,
    data_f date,
    motivo varchar not null,
    div_osp varchar not null, 
    paziente dom_cf not null
                    references paziente(cf) 
                    on update cascade 
                    on delete cascade
);

create table diagnosi (
    cod_dia dom_dia primary key,
    data_dia date not null,
    cod_pat ICD10 not null,
    grav_pat boolean not null,
    medico varchar(16) not null,
    paziente dom_cf not null 
                    references paziente(cf) 
                    on update cascade 
                    on delete cascade,
    ricovero dom_ric not null
                     references ricovero(cod_ric) 
                     on update cascade 
                     on delete no action
);

create table farmaco (
    nome_comm varchar primary key,
    azienda_prod varchar not null,
    dose_gg_racc int not null
);

create table principio_attivo (
    nome varchar primary key
);

create table contiene (
    farmaco varchar references farmaco(nome_comm) 
                    on update cascade 
                    on delete cascade,
    pr_attivo varchar references principio_attivo(nome) 
                      on update cascade 
                      on delete cascade,
    quantità int not null,
    primary key (farmaco, pr_attivo)
);

create table terapia (
    cod_ter dom_ter primary key,
    dose_gio int not null,
    mod_somm varchar not null,
    farmaco varchar not null
                    references farmaco(nome_comm) 
                    on update cascade 
                    on delete cascade
);

create table terapia_prescritta (
    data_i date not null,
    data_f date not null,
    med_presc varchar(16) not null,
    cod_dia dom_dia references diagnosi(cod_dia) 
                    on update cascade 
                    on delete no action, 
    cod_ter dom_ter references terapia(cod_ter) 
                    on update cascade 
                    on delete no action,
    primary key (cod_dia, cod_ter)
);


create or replace function ricalcolo_gg(cf_paz)
returns int
language plpgsql as $$
    declare
        gg int;
    begin

        select sum(ricovero.data_f - ricovero.data_i) into gg
        from paziente join ricovero on paziente.cf = ricovero.paziente
        where paziente.cf = cf_paz ;

        return gg;
    end
$$





-----------------------------------------------------------------------
-- TODO TRIGGERS --
-----------------------------------------------------------------------

-- PAZIENTE almeno un RICOVERO
    -- quando aggiungi PAZIENTE
    -- quando rimuovi RICOVERO
    -- quando modifichi campo Paziente in RICOVERO

-- Totale_Giorni_Ricoveri
    -- quando aggiungi PAZIENTE (inizializzazione?)
    -- quando aggiungi RICOVERO
    -- quando rimuovi RICOVERO
    -- quando modifichi campo Data Inizio in RICOVERO
    -- quando modifichi campo Data Fine in RICOVERO
    -- quando modifichi campo Paziente in RICOVERO

-- TERAPIA_PRESCRITTA DIAGNOSI->DIAGNOSI no uguale o precedente
    -- modifica campo Effetto_Collaterale
    -- problema modifica Diagnsi in T_P non si pone perchè in quel caso disfi e rifai tupla
    -- TODO

-- TERAPIA almeno una TERAPIA_PRESCRITTA
    -- quando aggiungi TERAPIA
    -- quando rimuovi TERAPIA_PRESCRITTA
    -- problema modifica Terapia in T_P non si pone perchè in quel caso disfi e rifai tupla

-- FARMACO almeno un PRINCIPIO_ATTIVO
  -- il check da fare su CONTIENE
    -- quando aggiungi FARMACO
    -- quando rimuovi PRINCIPIO_ATTIVO
    -- quando rimuovi tupla da CONTIENE

-- PRINCIPIO_ATTIVO almeno un FARMACO
  -- il check da fare su CONTIENE
    -- quando aggiungi PRINCIPIO_ATTIVO
    -- quando rimuovi FARMACO
    -- quando rimuovi tupla da CONTIENE
