-- Nenhuma coleta pode se perder no caminho: a fato precisa ter
-- o mesmo número de linhas que o staging (2.686.331).
select
    (select count(*) from {{ ref('stg_precos_unificados') }}) as linhas_staging,
    (select count(*) from {{ ref('fato_preco') }})            as linhas_fato
where (select count(*) from {{ ref('stg_precos_unificados') }})
   <> (select count(*) from {{ ref('fato_preco') }})
