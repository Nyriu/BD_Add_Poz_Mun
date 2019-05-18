drop schema ospedale cascade;

-- set search_path to ospedale;
-- drop table terapia_prescritta; drop table terapia;
-- drop table diagnosi;
-- drop table contiene;
-- drop table farmaco;
-- drop table principio_attivo;
-- drop table ricovero;
-- drop table paziente;
-- 
-- drop domain dom_cf;
-- drop domain dom_dia;
-- drop domain dom_ric;
-- drop domain dom_ter;
-- drop domain ICD10;
-- drop schema ospedale;


----------------------------------------------------------------
-- COPIARE DA QUI IN POI PER CREARE LE TABELLE LA PRIMA VOLTA --
----------------------------------------------------------------

create schema ospedale;
set search_path to ospedale;

create domain dom_cf as varchar
    check ( value ~ '^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$' ); -- es MRARSS80A01F205W
    
create sequence dom_ric_seq;
create domain dom_ric as int default nextval('dom_ric_seq');

create sequence dom_dia_seq;
create domain dom_dia as int default nextval('dom_dia_seq');

create sequence dom_ter_seq;
create domain dom_ter as int default nextval('dom_ter_seq');

create sequence dom_pa_seq;
create domain dom_pa as int default nextval('dom_pa_seq');

create domain ICD10 as varchar
    check ( value ~ '^[A-Z]([A-Z]|[0-9]){2}((\.)([0-9])*)?$'); 


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
    medico varchar not null,
    ricovero dom_ric not null
                     references ricovero(cod_ric) 
                     on update cascade 
                     on delete no action,
    -- viene inserito in automatico sfruttando ricovero
    paziente dom_cf references paziente(cf)
                    on update cascade 
                    on delete cascade
);

create table farmaco (
    nome_comm varchar primary key,
    azienda_prod varchar not null,
    dose_gg_racc int not null
);

create table principio_attivo (
    cod_pa dom_pa primary key,
    nome varchar
);

create table contiene (
    farmaco varchar references farmaco(nome_comm) 
                    on update cascade 
                    on delete cascade,
    pr_attivo dom_pa references principio_attivo(cod_pa) 
                      on update cascade 
                      on delete cascade,
    quantita varchar not null,
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
    med_presc varchar not null,
    diagnosi dom_dia unique references diagnosi(cod_dia)
                    on update cascade 
                    on delete no action, 
    terapia dom_ter references terapia(cod_ter) 
                    on update cascade 
                    on delete no action,
    coll_dia dom_dia unique references diagnosi(cod_dia)
                    on update cascade 
                    on delete no action, 
    primary key (diagnosi, terapia)
);


create or replace function ricalcolo_gg(cf_paz dom_cf)
returns int
language plpgsql as $$
    declare
        gg int;
    begin
        --TODO 2000/01/01 - 2000/01/01 = 0 ma e' stato in ric un giorno quindi +1?
        select sum(ricovero.data_f-ricovero.data_i) into gg
        from paziente
          join ricovero on paziente.cf = ricovero.paziente
        where paziente.cf = cf_paz;
        return gg;
    end
$$;



-----------------------------------------------------------------------
-- CONSTRAIN --
-----------------------------------------------------------------------

-- CONSTRAINTS sulle date
  -- RICOVERO e TERAPIA_PRESCRITTA data_i < data_f
  -- DIAGNOSI deve avere data compresa in data_i e data_f del RICOVERO
  -- data_i di TERAPIA_PRESCRITTA deve essere uguale o successiva alla data della diagnosi
create or replace function check_date_valide(data_i date, data_f date)
returns bool as
$$
  begin
    return data_i <= data_f;
  end;
$$ language plpgsql;

alter table ricovero add
  constraint check_date_valide_ric
    check(check_date_valide(data_i, data_f));

-- TODO testing
alter table terapia_prescritta add
  constraint check_date_valide_dia
    check(check_date_valide(data_i, data_f));


-- data diagnosi compresa in data_i data_f ricovero
create or replace function check_data_valida(data_dia date, ric dom_ric)
returns bool as
$$
  begin
    perform *
    from ricovero
    where ric = cod_ric and
          data_i <= data_dia  and
          (data_f >= data_dia or
            data_f is null);
    return found;
  end;
$$ language plpgsql;

alter table diagnosi add
  constraint check_data_valida_dia
    check(check_data_valida(data_dia, ricovero));


-- data_i terapia_prescritta uguale o successiva data_dia diagnosi
create or replace function check_data_valida_ter_pre(data date, dia dom_dia)
returns bool as
$$
  begin
    perform *
    from diagnosi
    where dia = cod_dia and
          data_dia <= data;
    return found;
  end;
$$ language plpgsql;

-- TODO testing
alter table terapia_prescritta add
  constraint check_data_valida_t_p
    check(check_data_valida_ter_pre(data_i, diagnosi));


-- TERAPIA_PRESCRITTA DIAGNOSI->DIAGNOSI no uguale o precedente
    -- aggiunta nuova T_P
    -- modifica dei campi
create or replace function check_dia_valide(data_i_ter date, dia dom_dia, coll_dia dom_dia)
returns bool as
$$
  begin
    if coll_dia is null
    then
      perform *
      from diagnosi
      where cod_dia = dia and
            data_dia <= data_i_ter;
      return found;
    else
      perform *
      from diagnosi d1, diagnosi d2
      where d1.cod_dia = dia and
            d2.cod_dia = coll_dia and
            d1.data_dia <= data_i_ter and
            data_i_ter <= d2.data_dia;
      return found;
    end if;
  end;
$$ language plpgsql;

-- TODO testing
alter table terapia_prescritta add
  constraint check_dia_valide
    check(check_dia_valide(data_i, diagnosi, coll_dia));





-----------------------------------------------------------------------
-- TODO TRIGGERS --
-----------------------------------------------------------------------

-- PAZIENTE almeno un RICOVERO
    -- quando aggiungi PAZIENTE
    -- quando rimuovi RICOVERO
    -- quando modifichi campo Paziente in RICOVERO
  -- TODO nella relazione scrivere che questo non va implementato per evitare dipendenze cicliche
  -- Soluzione: creare una funzione che di tanto in tanto pulisca i pazienti senza ricoveri
  -- (per il nostro dominio è una cosa strana che vengano cancellati ricoveri)

-- TENTATIVO FALLITO CON CONSTRAINT
-- create or replace function check_almeno_un_ric(cf dom_cf)
-- returns bool as
-- $$
--   begin
--     perform *
--     from ricovero
--     where paziente = cf;
--     return found;
--   end;
-- $$ language plpgsql;
-- 
-- -- TODO testing
-- alter table paziente add
--   deferrable constraint check_almeno_un_ric
--     check(check_almeno_un_ric(cf));
--ERRORE:  un vincolo CHECK non può essere marcato DEFERRABLE
--FINE TENTATIVO FALLITO CON CONSTRAINT


-- Totale_Giorni_Ricoveri
    -- quando aggiungi RICOVERO
    -- quando rimuovi RICOVERO
    -- quando modifichi campo Data Inizio in RICOVERO
    -- quando modifichi campo Data Fine in RICOVERO
    -- quando modifichi campo Paziente in RICOVERO
create or replace function aggiorna_gg_insert()
returns trigger as
$$
  begin
    -- inserito nuovo ric
    update paziente
    set tot_gg_ric = ricalcolo_gg(new.paziente)
    where paziente.cf = new.paziente;
    return new;
  end;
$$ language plpgsql;

create or replace function aggiorna_gg_update()
returns trigger as
$$
  begin
    update paziente
    set tot_gg_ric = ricalcolo_gg(new.paziente)
    where paziente.cf = new.paziente;

    -- se ho cambiato paziente devo anche ricalcolare
    -- il valore per il vecchio senza ricovero
    if new.paziente <> old.paziente
      then
      update paziente
      set tot_gg_ric = ricalcolo_gg(old.paziente)
      where paziente.cf = old.paziente;
    end if;

    return new;
  end;
$$ language plpgsql;

create trigger aggiornamento_gg_insert after insert
  on ricovero for each row
  execute procedure aggiorna_gg_insert();

create trigger aggiornamento_gg_update after update
  on ricovero for each row
    when ( new.data_i <> old.data_i or
           new.data_f <> old.data_f or
           old.data_i is null       or
           old.data_f is null       or
           new.paziente <> old.paziente )
      execute procedure aggiorna_gg_update();


-- DIAGNOSI stesso paziente del RICVOERO (Effettuata A)
  -- quando
    -- aggiunta nuova diagnosi
    -- update paziente nel ricovero -- NON serve perché cascade

create or replace function get_paziente(ric dom_ric)
returns dom_cf as
$$
  declare
      paz dom_cf;
  begin
    select paziente into paz
    from ricovero
    where cod_ric = ric;
    return paz;
  end;
$$ language plpgsql;

create or replace function init_paziente()
returns trigger as
$$
  begin
    new.paziente := get_paziente(new.ricovero);
    return new;
  end;
$$ language plpgsql;

create trigger init_paziente_dia before insert
  on diagnosi for each row
  execute procedure init_paziente();

create trigger update_paziente_dia before update
  on diagnosi
  for each row
  when ( new.paziente <> old.paziente or
         new.ricovero <> old.ricovero )
  execute procedure init_paziente();

-- DIAGNOSI una sola TERAPIA_PRESCRITTA TODO BASTA UNIQUE!!
    -- Diagnosi in T_P deve essere chiave, deve essere introdotto un vincolo che asscuri che una Diagnosi compaia una sola volta dentro tutta la tabella delel T_P

-- DIAGNOSI è effetto collaterale di una sola TERAPIA_PRESCRITTA TODO BASTA UNIQUE!!
    -- coll_dia in T_P deve essere chiave, deve essere introdotto un vincolo che asscuri che una coll_dia compaia una sola volta dentro tutta la tabella delel T_P


-- TERAPIA almeno una TERAPIA_PRESCRITTA
    -- quando aggiungi TERAPIA
    -- quando rimuovi TERAPIA_PRESCRITTA
    -- problema modifica Terapia in T_P non si pone perchè in quel caso disfi e rifai tupla
  -- se si facesse si introdurrebbe una dipendenza ciclica
  -- non potrei inserire una TERAPIA se prima non ho già una TERAPIA_PRESCRITTA
  -- cosa impossibile perche' T_P ha terapia come pezzo di chiave primaria
  -- TODO soluzione simile a quella per "PAZIENTE almeno un RICOVERO"



-- PRINCIPIO_ATTIVO almeno un FARMACO
  -- il check da fare su CONTIENE
    -- quando aggiungi PRINCIPIO_ATTIVO
    -- quando rimuovi FARMACO
    -- quando rimuovi tupla da CONTIENE
    -- quando aggiorni tupla da CONTIENE
-- FARMACO almeno un PRINCIPIO_ATTIVO
  -- il check da fare su CONTIENE
    -- NO -- quando aggiungi FARMACO
    -- quando rimuovi PRINCIPIO_ATTIVO -- coperto dal trigger che rimuove tupla da contiene.. dato cascade in P_A
    -- quando rimuovi tupla da CONTIENE
    -- quando aggiorni tupla da CONTIENE
-- Per evitare dipendenze cicliche permetto ad un P_A di rimanere senza FARMACI
-- TODO soluzione simile a quella per "PAZIENTE almeno un RICOVERO"

create or replace function almeno_un_pa_cont()
returns trigger as
$$
  begin
    perform *
    from contiene
    where old.farmaco == farmaco and
          old.pr_attivo <> pr_attivo;
    if not found
    then
      raise exception 'Rimarrebbe senza principi attivi'; -- TODO dire meglio
      return null;
    else
      return new;
    end if;
  end;
$$ language plpgsql;

-- TODO testing
create trigger controlla_almeno_pa_del before delete
  on contiene for each row
    execute procedure almeno_un_pa_cont();

create trigger controlla_almeno_pa_up before update
  on contiene for each row
    when ( new.farmaco <> old.farmaco or
           new.pr_attivo <> old.pr_attivo)
    execute procedure almeno_un_pa_cont();
