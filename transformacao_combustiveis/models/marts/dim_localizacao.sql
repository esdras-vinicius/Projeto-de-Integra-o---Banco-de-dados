-- Dimensão localização: cada combinação de região, UF e município.
-- collate "C" ordena igual ao Python (pela tabela Unicode), para as
-- chaves saírem com os mesmos números do ETL.

with locais as (
    select distinct regiao, uf, municipio
    from {{ ref('int_precos_preparados') }}
)

select
    row_number() over (
        order by regiao collate "C", uf collate "C", municipio collate "C"
    ) as sk_localizacao,
    regiao,
    uf,
    municipio
from locais
