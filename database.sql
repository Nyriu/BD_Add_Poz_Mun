drop schema ospedale cascade;

create schema ospedale;
set search_path to ospedale;

create table paziente (
    cf 
    cognome
    nome
    data_di_nascita
    luogo_di_nascita
    provincia_di_residenza
    regione_di_appartenenza
    ulss
    totale_giorni_ricovero
);

create table ricovero (
    codice_ricovero
    data_inizio
    data_fine
    motivo
    divisione_ospedaliera
);

create table diagnosi (
    codice_diagnosi
    data_diagnosi
    codice_patologia
    gravita_patologia
    medico
);

create table terapia (
    codice_terapia
    dose_giornaliera
    modalita_somministrazione
);

create table terapia_prescritta (
    data_inizio
    data_fine
    medico_prescrivente
    codice_diagnosi
    codice_terapia
);

create table farmaco (
    nome_commerciale
    azienda_produttrice
    dose_giornaliera_raccomandata
);

create table principio attivo (
    nome
);

create table contiene (
    farmaco
    principio_attivo
    quantità
);