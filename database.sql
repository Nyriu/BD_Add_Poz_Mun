drop schema ospedale cascade;

create schema ospedale;
set search_path to ospedale;

create table paziente (
    cf varchar(16) primary key,
    cognome varchar not null,
    nome varchar not null,
    data_di_nascita date not null,
    luogo_di_nascita date not null,
    provincia_di_residenza varchar(2) not null,
    regione_di_appartenenza varchar,
    ulss varchar,
    totale_giorni_ricovero int, -- dove si aggiunge il conto?
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
    codice_terapia varchar(20) references terapia
);

create table farmaco (
    nome_commerciale varchar primary key,
    azienda_produttrice varchar,
    dose_giornaliera_raccomandata int,
);

create table principio_attivo (
    nome varchar primary key,
);

create table contiene (
    farmaco varchar references farmaco,
    principio_attivo varchar references principio_attivo,
    quantità int
);