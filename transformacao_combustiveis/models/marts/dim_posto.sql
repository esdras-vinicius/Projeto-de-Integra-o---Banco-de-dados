WITH ultimo_cadastro AS (
    SELECT DISTINCT ON (cnpj)
        cnpj,
        razao_social,
        rua,
        numero_rua,
        bairro,
        cep,
        data_coleta AS ultima_coleta
    FROM {{ ref('int_precos_limpos') }}
    ORDER BY cnpj, data_coleta DESC
)
SELECT
    ROW_NUMBER() OVER (ORDER BY ultima_coleta ASC, cnpj COLLATE "C" ASC)::INTEGER AS sk_posto,
    cnpj::CHAR(14) AS cnpj,
    razao_social,
    rua,
    numero_rua,
    bairro,
    cep::CHAR(8) AS cep
FROM ultimo_cadastro
ORDER BY sk_posto
