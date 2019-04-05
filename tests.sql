set search_path to ospedale;

drop table diagnosi;
drop domain icd10;
drop domain dom_dia;

create domain ICD10 as varchar
    check ( value ~ ('^[A-Z]([A-Z]|[0-9]){2}((\.)([0-9])*)?$'));

create domain dom_dia as varchar
    check ( value ~ ('DIA' || '[0-9]+'));


create table diagnosi (
    cod_dia dom_dia primary key,
    cod_pat ICD10
);

insert into diagnosi(cod_dia, cod_pat)
    values
    ('DIA1','T90'),
    ('DIA100','C34.3435'),
	('DIA250','CAA4.3435.366');

select cod_dia, cod_pat from diagnosi;