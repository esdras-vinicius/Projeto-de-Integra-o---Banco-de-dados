-- Fato preço: uma linha por coleta (data, posto e produto).
-- Cada coleta limpa busca nas dimensões a chave sk_ correspondente.

with precos as (
    select * from {{ ref('int_precos_preparados') }}
)

select
    t.sk_tempo,
    po.sk_posto,
    pr.sk_produto,
    b.sk_bandeira,
    l.sk_localizacao,
    p.valor_venda,
    p.fl_outlier,
    p.arquivo_origem
from precos p
join {{ ref('dim_tempo') }} t
    on t.data = p.data_coleta
join {{ ref('dim_posto') }} po
    on po.cnpj = p.cnpj
join {{ ref('dim_produto') }} pr
    on pr.produto = p.produto
   and pr.unidade_medida = p.unidade_medida
join {{ ref('dim_bandeira') }} b
    on b.bandeira_original = p.bandeira_original
   and b.bandeira_padronizada = p.bandeira_padronizada
join {{ ref('dim_localizacao') }} l
    on l.regiao = p.regiao
   and l.uf = p.uf
   and l.municipio = p.municipio
