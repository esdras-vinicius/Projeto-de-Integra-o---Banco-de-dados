-- Compara o DW do ETL (dw_etl, pandas) com o DW do ELT (dw_elt, dbt), linha por linha.
-- Rodar depois do ETL.ipynb e do dbt build:
--   psql -U postgres -h localhost -d anp_dw -f sql/02_comparar_etl_elt.sql
-- Esperado: linhas iguais nos dois lados e 0 nas colunas so_no_etl e so_no_elt.
--   so_no_etl = linhas que existem só no dw_etl
--   so_no_elt = linhas que existem só no dw_elt
-- EXCEPT ALL conta linhas repetidas, então uma linha duplicada também aparece.
-- O id_preco da fato fica de fora: é só um contador, cada pipeline numera do seu jeito.

select 'dim_tempo' as tabela,
  (select count(*) from dw_etl.dim_tempo) as linhas_etl,
  (select count(*) from dw_elt.dim_tempo) as linhas_elt,
  (select count(*) from (select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_etl.dim_tempo
     except all select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_elt.dim_tempo) a) as so_no_etl,
  (select count(*) from (select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_elt.dim_tempo
     except all select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_etl.dim_tempo) a) as so_no_elt
union all
select 'dim_posto' as tabela,
  (select count(*) from dw_etl.dim_posto) as linhas_etl,
  (select count(*) from dw_elt.dim_posto) as linhas_elt,
  (select count(*) from (select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_etl.dim_posto
     except all select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_elt.dim_posto) a) as so_no_etl,
  (select count(*) from (select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_elt.dim_posto
     except all select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_etl.dim_posto) a) as so_no_elt
union all
select 'dim_localizacao' as tabela,
  (select count(*) from dw_etl.dim_localizacao) as linhas_etl,
  (select count(*) from dw_elt.dim_localizacao) as linhas_elt,
  (select count(*) from (select sk_localizacao,regiao,uf,municipio from dw_etl.dim_localizacao
     except all select sk_localizacao,regiao,uf,municipio from dw_elt.dim_localizacao) a) as so_no_etl,
  (select count(*) from (select sk_localizacao,regiao,uf,municipio from dw_elt.dim_localizacao
     except all select sk_localizacao,regiao,uf,municipio from dw_etl.dim_localizacao) a) as so_no_elt
union all
select 'dim_produto' as tabela,
  (select count(*) from dw_etl.dim_produto) as linhas_etl,
  (select count(*) from dw_elt.dim_produto) as linhas_elt,
  (select count(*) from (select sk_produto,produto,unidade_medida from dw_etl.dim_produto
     except all select sk_produto,produto,unidade_medida from dw_elt.dim_produto) a) as so_no_etl,
  (select count(*) from (select sk_produto,produto,unidade_medida from dw_elt.dim_produto
     except all select sk_produto,produto,unidade_medida from dw_etl.dim_produto) a) as so_no_elt
union all
select 'dim_bandeira' as tabela,
  (select count(*) from dw_etl.dim_bandeira) as linhas_etl,
  (select count(*) from dw_elt.dim_bandeira) as linhas_elt,
  (select count(*) from (select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_etl.dim_bandeira
     except all select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_elt.dim_bandeira) a) as so_no_etl,
  (select count(*) from (select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_elt.dim_bandeira
     except all select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_etl.dim_bandeira) a) as so_no_elt
union all
select 'fato_preco' as tabela,
  (select count(*) from dw_etl.fato_preco) as linhas_etl,
  (select count(*) from dw_elt.fato_preco) as linhas_elt,
  (select count(*) from (select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_etl.fato_preco
     except all select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_elt.fato_preco) a) as so_no_etl,
  (select count(*) from (select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_elt.fato_preco
     except all select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_etl.fato_preco) a) as so_no_elt;
