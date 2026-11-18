-- Camada de staging do ELT.
-- Junta os seis semestres crus (schema raw_anp) em uma única tabela, sem limpar nada.
-- A única coluna nova é arquivo_origem, escrita igual à do ETL ('ca-2018-01.csv'),
-- para que os dois pipelines possam ser comparados linha a linha.

{{ config(materialized='view') }}

select *, 'ca-2018-01.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2018_01') }}
union all
select *, 'ca-2018-02.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2018_02') }}
union all
select *, 'ca-2019-01.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2019_01') }}
union all
select *, 'ca-2019-02.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2019_02') }}
union all
select *, 'ca-2020-01.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2020_01') }}
union all
select *, 'ca-2020-02.csv' as arquivo_origem from {{ source('anp_bruto', 'ca_2020_02') }}
