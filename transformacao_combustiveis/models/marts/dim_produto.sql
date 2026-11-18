WITH produtos AS (
    SELECT DISTINCT
        produto,
        unidade_medida
    FROM {{ ref('int_precos_limpos') }}
)
SELECT
    ROW_NUMBER() OVER (ORDER BY produto COLLATE "C")::INTEGER AS sk_produto,
    produto,
    unidade_medida
FROM produtos
ORDER BY sk_produto
