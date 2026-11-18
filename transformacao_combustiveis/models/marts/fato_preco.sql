SELECT
    ROW_NUMBER() OVER (
        ORDER BY p.arquivo_origem, p.data_coleta, p.cnpj, p.produto
    )::BIGINT AS id_preco,
    t.sk_tempo,
    po.sk_posto,
    pr.sk_produto,
    b.sk_bandeira,
    l.sk_localizacao,
    p.valor_venda,
    p.fl_outlier,
    p.arquivo_origem
FROM {{ ref('int_precos_limpos') }} p
INNER JOIN {{ ref('dim_tempo') }} t
    ON p.data_coleta = t.data
INNER JOIN {{ ref('dim_posto') }} po
    ON p.cnpj = po.cnpj
INNER JOIN {{ ref('dim_produto') }} pr
    ON p.produto = pr.produto
   AND p.unidade_medida = pr.unidade_medida
INNER JOIN {{ ref('dim_bandeira') }} b
    ON p.bandeira_original = b.bandeira_original
   AND p.bandeira_padronizada = b.bandeira_padronizada
INNER JOIN {{ ref('dim_localizacao') }} l
    ON p.regiao = l.regiao
   AND p.uf = l.uf
   AND p.municipio = l.municipio
