WITH base_limpa AS (
    SELECT
        NULLIF(TRIM(regiao_sigla), '') AS regiao,
        NULLIF(TRIM(estado_sigla), '') AS uf,
        NULLIF(TRIM(municipio), '') AS municipio,
        NULLIF(TRIM(revenda), '') AS razao_social,
        REGEXP_REPLACE(NULLIF(TRIM(cnpj_revenda), ''), '\D', '', 'g') AS cnpj,
        NULLIF(TRIM(nome_rua), '') AS rua,
        REGEXP_REPLACE(
            UPPER(COALESCE(NULLIF(TRIM(numero_rua), ''), 'S/N')),
            '^(?:S\s*/?\s*N\.?\s*[º°O]?|SNR|SN)$',
            'S/N'
        ) AS numero_rua,
        NULLIF(TRIM(bairro), '') AS bairro,
        REGEXP_REPLACE(NULLIF(TRIM(cep), ''), '\D', '', 'g') AS cep,
        NULLIF(TRIM(produto), '') AS produto,
        TO_DATE(NULLIF(TRIM(data_coleta), ''), 'DD/MM/YYYY') AS data_coleta,
        REPLACE(NULLIF(TRIM(valor_venda), ''), ',', '.')::NUMERIC(12, 4) AS valor_venda,
        NULLIF(TRIM(unidade_medida), '') AS unidade_medida,
        NULLIF(TRIM(bandeira), '') AS bandeira_original,
        CASE NULLIF(TRIM(bandeira), '')
            WHEN 'PETROX DISTRIBUIDORA' THEN 'PETROX'
            WHEN 'ALE COMBUSTÍVEIS' THEN 'ALESAT'
            ELSE NULLIF(TRIM(bandeira), '')
        END AS bandeira_padronizada,
        arquivo_origem
    FROM {{ ref('stg_precos_unificados') }}
),
quartis AS (
    SELECT
        produto,
        DATE_TRUNC('month', data_coleta)::DATE AS ano_mes,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY valor_venda) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY valor_venda) AS q3
    FROM base_limpa
    GROUP BY produto, DATE_TRUNC('month', data_coleta)::DATE
)
SELECT
    b.*,
    (
        b.valor_venda < (q.q1 - 3 * (q.q3 - q.q1))
        OR b.valor_venda > (q.q3 + 3 * (q.q3 - q.q1))
    ) AS fl_outlier
FROM base_limpa b
INNER JOIN quartis q
    ON b.produto = q.produto
   AND DATE_TRUNC('month', b.data_coleta)::DATE = q.ano_mes
