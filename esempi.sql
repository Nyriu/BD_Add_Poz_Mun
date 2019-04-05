

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
insert into paziente(cf, cognome, nome, data_nasc, luogo_nasc, prov_res, reg_app)
	values 
	('RSSMRA80A01F205X', 'Rossi', 'Mario', '1980-01-01', 'Milano', 'MI', 'Lombardia');


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
