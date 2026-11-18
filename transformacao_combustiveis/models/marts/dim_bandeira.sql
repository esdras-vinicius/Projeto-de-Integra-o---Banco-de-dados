WITH bandeiras AS (
    SELECT DISTINCT
        bandeira_original,
        bandeira_padronizada
    FROM {{ ref('int_precos_limpos') }}
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY bandeira_padronizada COLLATE "C", bandeira_original COLLATE "C"
    )::INTEGER AS sk_bandeira,
    bandeira_original,
    bandeira_padronizada,
    (bandeira_padronizada = 'BRANCA') AS fl_branca
FROM bandeiras
ORDER BY sk_bandeira
