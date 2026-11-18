-- Dimensão posto: um posto por CNPJ, com o cadastro da coleta mais recente
-- (mesma regra do ETL). 38 postos mudam de nome ou endereço no período.
-- A chave segue a ordem da última coleta e, em empate, o CNPJ.

with ultimo_cadastro as (
    select distinct on (cnpj)
        cnpj,
        revenda     as razao_social,
        nome_rua    as rua,
        numero_rua,
        bairro,
        cep,
        data_coleta as ultima_coleta
    from {{ ref('int_precos_preparados') }}
    order by cnpj, data_coleta desc
)

select
    row_number() over (order by ultima_coleta, cnpj collate "C") as sk_posto,
    cnpj,
    razao_social,
    rua,
    numero_rua,
    bairro,
    cep
from ultimo_cadastro
