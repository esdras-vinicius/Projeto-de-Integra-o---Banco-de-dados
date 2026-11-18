-- Compara o DW do ETL (dw_etl, pandas) com o DW do ELT (dw_elt, dbt), linha por linha.
-- Rodar depois do ETL.ipynb e do dbt build:
--   psql -U postgres -h localhost -d anp_dw -f sql/02_comparar_etl_elt.sql
-- Esperado: 0 nas duas colunas em todas as tabelas.
--   so_no_etl = linhas que existem só no dw_etl
--   so_no_elt = linhas que existem só no dw_elt

select 'dim_tempo' tabela,
  (select count(*) from (select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_etl.dim_tempo
     except select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_elt.dim_tempo) a) so_no_etl,
  (select count(*) from (select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_elt.dim_tempo
     except select sk_tempo,data,dia,mes,nome_mes,trimestre,semestre,ano,dia_semana,periodo_historico from dw_etl.dim_tempo) a) so_no_elt
union all select 'dim_posto',
  (select count(*) from (select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_etl.dim_posto
     except select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_elt.dim_posto) a),
  (select count(*) from (select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_elt.dim_posto
     except select sk_posto,cnpj,razao_social,rua,numero_rua,bairro,cep from dw_etl.dim_posto) a)
union all select 'dim_localizacao',
  (select count(*) from (select sk_localizacao,regiao,uf,municipio from dw_etl.dim_localizacao
     except select sk_localizacao,regiao,uf,municipio from dw_elt.dim_localizacao) a),
  (select count(*) from (select sk_localizacao,regiao,uf,municipio from dw_elt.dim_localizacao
     except select sk_localizacao,regiao,uf,municipio from dw_etl.dim_localizacao) a)
union all select 'dim_produto',
  (select count(*) from (select sk_produto,produto,unidade_medida from dw_etl.dim_produto
     except select sk_produto,produto,unidade_medida from dw_elt.dim_produto) a),
  (select count(*) from (select sk_produto,produto,unidade_medida from dw_elt.dim_produto
     except select sk_produto,produto,unidade_medida from dw_etl.dim_produto) a)
union all select 'dim_bandeira',
  (select count(*) from (select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_etl.dim_bandeira
     except select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_elt.dim_bandeira) a),
  (select count(*) from (select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_elt.dim_bandeira
     except select sk_bandeira,bandeira_original,bandeira_padronizada,fl_branca from dw_etl.dim_bandeira) a)
union all select 'fato_preco',
  (select count(*) from (select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_etl.fato_preco
     except select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_elt.fato_preco) a),
  (select count(*) from (select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_elt.fato_preco
     except select sk_tempo,sk_posto,sk_produto,sk_bandeira,sk_localizacao,valor_venda,fl_outlier,arquivo_origem from dw_etl.fato_preco) a);
