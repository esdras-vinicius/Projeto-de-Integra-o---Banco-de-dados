-- Dimensão bandeira: o nome como veio no CSV e o nome padronizado pelo de-para.

with bandeiras as (
    select distinct bandeira_original, bandeira_padronizada
    from {{ ref('int_precos_preparados') }}
)

select
    row_number() over (
        order by bandeira_padronizada collate "C", bandeira_original collate "C"
    ) as sk_bandeira,
    bandeira_original,
    bandeira_padronizada,
    bandeira_padronizada = 'BRANCA' as fl_branca
from bandeiras
