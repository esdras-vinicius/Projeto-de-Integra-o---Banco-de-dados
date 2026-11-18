-- Dimensão produto: cada combustível com a sua unidade de medida.

with produtos as (
    select distinct produto, unidade_medida
    from {{ ref('int_precos_preparados') }}
)

select
    row_number() over (order by produto collate "C") as sk_produto,
    produto,
    unidade_medida
from produtos
