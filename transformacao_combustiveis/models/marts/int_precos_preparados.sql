-- Camada intermediária do ELT: a limpeza.
-- Reproduz em SQL, na mesma ordem, as etapas 3 a 7 do ETL.ipynb.
-- Cada CTE (bloco "with") corresponde a uma etapa do notebook.

with staging as (
    select * from {{ ref('stg_precos_unificados') }}
),

-- Etapa 3 do ETL: tirar espaços do começo e do fim; texto vazio vira NULL
sem_espacos as (
    select
        {{ limpar_texto('regiao_sigla') }}   as regiao,
        {{ limpar_texto('estado_sigla') }}   as uf,
        {{ limpar_texto('municipio') }}      as municipio,
        {{ limpar_texto('revenda') }}        as revenda,
        {{ limpar_texto('cnpj_revenda') }}   as cnpj_revenda,
        {{ limpar_texto('nome_rua') }}       as nome_rua,
        {{ limpar_texto('numero_rua') }}     as numero_rua,
        {{ limpar_texto('bairro') }}         as bairro,
        {{ limpar_texto('cep') }}            as cep,
        {{ limpar_texto('produto') }}        as produto,
        {{ limpar_texto('data_coleta') }}    as data_coleta,
        {{ limpar_texto('valor_venda') }}    as valor_venda,
        {{ limpar_texto('unidade_medida') }} as unidade_medida,
        {{ limpar_texto('bandeira') }}       as bandeira,
        arquivo_origem
    from staging
),

-- Etapas 4 e 5 do ETL: CNPJ e CEP só com dígitos, número "sem número" como S/N,
-- data como DATE e preço com ponto decimal
padronizado as (
    select
        regiao,
        uf,
        municipio,
        revenda,
        nome_rua,
        bairro,
        produto,
        unidade_medida,
        bandeira,
        arquivo_origem,
        regexp_replace(cnpj_revenda, '\D', '', 'g') as cnpj,
        regexp_replace(cep, '\D', '', 'g')          as cep,
        case
            when upper(coalesce(numero_rua, 'S/N')) ~ '^(S\s*/?\s*N\.?\s*[º°O]?|SNR|SN)$'
                then 'S/N'
            else upper(coalesce(numero_rua, 'S/N'))
        end                                         as numero_rua,
        to_date(data_coleta, 'DD/MM/YYYY')          as data_coleta,
        replace(valor_venda, ',', '.')::numeric     as valor_venda
    from sem_espacos
),

-- Etapa 6 do ETL: padronizar bandeiras com a tabela de-para (seed)
com_bandeira as (
    select
        p.*,
        p.bandeira                                         as bandeira_original,
        coalesce(dp.bandeira_padronizada, p.bandeira)      as bandeira_padronizada
    from padronizado p
    left join {{ ref('de_para_bandeira') }} dp
        on dp.bandeira_original = p.bandeira
),

-- Etapa 7 do ETL: quartis do preço por produto e mês.
-- percentile_cont interpola entre os valores, igual ao quantile() do pandas.
-- As contas são feitas em double precision, como o float do pandas.
quartis as (
    select
        produto,
        date_trunc('month', data_coleta) as ano_mes,
        percentile_cont(0.25) within group (order by valor_venda::double precision) as q1,
        percentile_cont(0.75) within group (order by valor_venda::double precision) as q3
    from com_bandeira
    group by produto, date_trunc('month', data_coleta)
)

select
    b.regiao,
    b.uf,
    b.municipio,
    b.revenda,
    b.cnpj,
    b.nome_rua,
    b.numero_rua,
    b.bairro,
    b.cep,
    b.produto,
    b.unidade_medida,
    b.data_coleta,
    b.valor_venda,
    b.bandeira_original,
    b.bandeira_padronizada,
    b.arquivo_origem,
    (
        b.valor_venda::double precision < q.q1 - 3 * (q.q3 - q.q1)
        or b.valor_venda::double precision > q.q3 + 3 * (q.q3 - q.q1)
    ) as fl_outlier
from com_bandeira b
join quartis q
    on q.produto = b.produto
   and q.ano_mes = date_trunc('month', b.data_coleta)
