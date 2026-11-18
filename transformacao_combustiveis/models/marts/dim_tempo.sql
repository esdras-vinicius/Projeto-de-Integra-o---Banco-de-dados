-- Dimensão tempo: um dia por linha, de 01/01/2018 a 31/12/2020,
-- inclusive os dias sem coleta (mesma regra do ETL).

with dias as (
    select dia::date as data
    from generate_series(date '2018-01-01', date '2020-12-31', interval '1 day') as dia
)

select
    data,
    to_char(data, 'YYYYMMDD')::integer      as sk_tempo,
    extract(day from data)::integer         as dia,
    extract(month from data)::integer       as mes,
    case extract(month from data)::integer
        when 1 then 'Janeiro'   when 2 then 'Fevereiro' when 3 then 'Março'
        when 4 then 'Abril'     when 5 then 'Maio'      when 6 then 'Junho'
        when 7 then 'Julho'     when 8 then 'Agosto'    when 9 then 'Setembro'
        when 10 then 'Outubro'  when 11 then 'Novembro' when 12 then 'Dezembro'
    end                                     as nome_mes,
    extract(quarter from data)::integer     as trimestre,
    case when extract(month from data) <= 6 then 1 else 2 end as semestre,
    extract(year from data)::integer        as ano,
    case extract(isodow from data)::integer
        when 1 then 'Segunda-feira' when 2 then 'Terça-feira' when 3 then 'Quarta-feira'
        when 4 then 'Quinta-feira'  when 5 then 'Sexta-feira' when 6 then 'Sábado'
        when 7 then 'Domingo'
    end                                     as dia_semana,
    case
        when data <  date '2018-05-21' then 'Pré-Greve 2018'
        when data <= date '2018-06-05' then 'Greve Caminhoneiros 2018'
        when data <  date '2020-03-11' then 'Normalidade 2018-2019'
        else 'Pandemia 2020'
    end                                     as periodo_historico
from dias
