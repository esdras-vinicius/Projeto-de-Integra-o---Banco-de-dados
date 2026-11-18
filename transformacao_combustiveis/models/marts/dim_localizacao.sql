WITH locais AS (
    SELECT DISTINCT
        regiao,
        uf,
        municipio
    FROM {{ ref('int_precos_limpos') }}
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY regiao COLLATE "C", uf COLLATE "C", municipio COLLATE "C"
    )::INTEGER AS sk_localizacao,
    regiao,
    uf::CHAR(2) AS uf,
    municipio
FROM locais
ORDER BY sk_localizacao
