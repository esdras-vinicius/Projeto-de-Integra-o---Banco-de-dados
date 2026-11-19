# Projeto de Integração de Dados: Preços de Combustíveis ANP (2018–2020)

Este repositório centraliza o projeto prático de Engenharia e Análise de Dados voltado à construção de um **Data Warehouse** modelado em **Esquema Estrela**. O objetivo é consolidar três anos consecutivos (2018, 2019 e 2020) da Série Histórica de Preços de Combustíveis da **ANP**, aplicando e comparando os paradigmas **ETL** e **ELT** a partir do tratamento de tabelas sujas para tabelas limpas.

---

## Estratégia de Dados: Tabelas Sujas e Tabelas Limpas

O fluxo de integração do projeto organiza os dados em duas camadas principais de maturidade:

* **Tabelas Sujas (Camada Bruta / *Staging*):** Correspondem aos dados originais extraídos diretamente dos arquivos CSV da ANP (`dados/sujo/ca-2018-01.csv` a `ca-2020-02.csv`), sem alterações estruturais. Essa camada preserva inconsistências reais da fonte, como delimitadores por ponto e vírgula (`;`), valores decimais com vírgula, variações de *encoding* (`ISO-8859-1` / `UTF-8`), registros duplicados e ausência de colunas (como o `Valor de Compra` no 2º semestre de 2020). No pipeline **ELT**, esses dados são carregados integralmente como tabelas sujas no banco de dados antes da etapa de transformação.
* **Tabelas Limpas (Camada Tratada / *Data Warehouse*):** Representam os dados após higienização, padronização de textos e datas, conversão de tipos numéricos, tratamento de valores nulos e criação de chaves substitutas (*surrogate keys*). No pipeline **ETL**, essa limpeza ocorre em memória via **Pandas** antes da carga; no **ELT**, ocorre via **SQL** dentro do próprio banco de dados, resultando nas tabelas finais do Esquema Estrela.

---

## Tecnologias e Ferramentas Utilizadas

* **Python 3 & Pandas:** Utilizados como motor principal no pipeline **ETL** para leitura dos CSVs sujos, limpeza de strings, conversão de tipos, tratamento de nulos e modelagem das tabelas limpas em memória.
* **Google Colab:** Ambiente em nuvem utilizado para o desenvolvimento, execução e documentação interativa dos notebooks de ETL e ELT.
* **SQL & Banco de Dados Relacional (PostgreSQL):** Utilizado para armazenar tanto as tabelas sujas (*Staging*) quanto as tabelas limpas finais (**Data Warehouse**), além de executar toda a lógica de limpeza e transformação via SQL no pipeline **ELT**.
* **Draw.io:** Ferramenta empregada na elaboração dos diagramas de arquitetura do fluxo de dados (ETL vs. ELT) e da modelagem dimensional (Esquema Estrela).
* **Git & GitHub:** Controle de versão distribuído para rastreabilidade das entregas individuais de cada integrante e centralização do código e relatórios.

---

## Base de Dados e Modelagem Dimensional

* **Fonte:** [Série Histórica de Preços de Combustíveis - ANP](https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis) (arquivos semestrais de `2018-01` a `2020-02`).
* **Arquitetura do Data Warehouse (Tabelas Limpas em Esquema Estrela):**
  * **`fato_preco` (Tabela Fato):** Grão de um preço por data, posto e produto. Contém a métrica `valor_venda`, a flag de qualidade `fl_outlier`, o `arquivo_origem` de cada registro e as chaves estrangeiras para as dimensões (`sk_tempo`, `sk_posto`, `sk_produto`, `sk_bandeira`, `sk_localizacao`).
  * **`dim_tempo` (Dimensão):** Data da coleta, ano, semestre, trimestre, mês e classificação do período histórico (ex.: *Pré-Greve*, *Greve 2018*, *Normalidade 2019*, *Pandemia 2020*).
  * **`dim_produto` (Dimensão):** Tipo de combustível (Gasolina Comum, Aditivada, Etanol, Diesel, Diesel S10) e unidade de medida.
  * **`dim_localizacao` (Dimensão):** Região, Unidade Federativa (UF) e Município.
  * **`dim_posto` (Dimensão):** CNPJ da revenda, razão social, bandeira (Branca, Petrobras/Vibra, Ipiranga, Raízen/Shell, etc.), bairro e CEP.

---

## Disposição de Diretórios
```text
Projeto-de-Integra-o---Banco-de-dados/
├── dados/
│   └── sujo/                          # CSVs brutos da ANP (ca-2018-01 a ca-2020-02)
├── notebooks/
│   ├── ETL.ipynb                      # Pipeline 1: ETL completo em Python (Pandas) -> dw_etl
│   └── ELT.ipynb                      # Pipeline 2: carga bruta (EL) + execução do dbt + comparação
├── sql/
│   ├── 01_criar_dw_etl.sql            # DDL do Data Warehouse do ETL (schema dw_etl)
│   └── 02_comparar_etl_elt.sql        # Consultas de comparação dw_etl x dw_elt
├── transformacao_combustiveis/        # Projeto dbt (Pipeline 2: Transformação) -> dw_elt
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_precos_unificados.sql   # UNION ALL das 6 tabelas brutas
│   │   │   └── schema.yml                  # sources + testes do staging
│   │   ├── intermediate/
│   │   │   └── int_precos_limpos.sql       # Limpeza intermediária
│   │   └── marts/                          # Modelos finais (Dimensões e Fato)
│   │       ├── dim_tempo.sql
│   │       ├── dim_posto.sql
│   │       ├── dim_localizacao.sql
│   │       ├── dim_produto.sql
│   │       ├── dim_bandeira.sql
│   │       ├── fato_preco.sql
│   │       └── schema.yml                  # testes das dimensões e da fato
│   ├── tests/                         # Testes singulares
│   │   ├── cnpj_cep_e_preco_validos.sql
│   │   ├── fato_grao_unico.sql
│   │   └── fato_tem_todas_as_coletas.sql
│   ├── macros/                        # (vazio, só .gitkeep)
│   ├── seeds/                         # (vazio, só .gitkeep)
│   └── dbt_project.yml
├── requirements.txt                   # pandas, sqlalchemy, psycopg2-binary, dbt-postgres, jupyter
├── .gitignore
└── README.md
```

---

## Ambiente Virtual

```bash
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

O servidor PostgreSQL precisa estar instalado e em execução separadamente.

---

## Como Executar o Projeto
 
### Pré-requisitos
 
1. Instale Python 3.10+ e PostgreSQL, e crie um banco vazio (ex.: `anp_dw`).
2. Clone este repositório e instale as dependências:
```bash
pip install -r requirements.txt
```
3. Defina a conexão por variáveis de ambiente, no terminal em que abrir o Jupyter:
```bash
export PGHOST=localhost PGDATABASE=anp_dw PGUSER=postgres PGPASSWORD=sua_senha
```
   (Windows PowerShell: `$env:PGHOST="localhost"` e assim por diante.)
 
### Passo 1: Pipeline ETL
 
Execute `notebooks/ETL.ipynb`. Ele limpa os CSVs de `dados/sujo/` com Pandas e grava o Data Warehouse no schema `dw_etl`.
 
### Passo 2: Pipeline ELT
 
1. Execute as seções 1 a 7 de `notebooks/ELT.ipynb`. Elas carregam os CSVs, sem tratamento, no schema `raw_anp`.
2. Configure o `profiles.yml` do dbt (`~/.dbt/`) com o profile `transformacao_combustiveis`, usando `schema: dw_elt`, e rode:
```bash
cd transformacao_combustiveis
dbt build
```
 
### Passo 3: Comparar ETL × ELT
 
```bash
psql -U postgres -d anp_dw -f sql/02_comparar_etl_elt.sql
```
 
O resultado esperado é `so_no_etl` e `so_no_elt` iguais a 0 em todas as tabelas.

---

## Resultados e Insights
 
As consultas SQL na pasta `/analysis` mostram o que o modelo em estrela permite responder:
 
1. **Insight 1:** descrição insight.
2. **Insight 2:** descrição insight.
3. **Insight 3:** descrição insight.

> **Insights:** _preencher depois de rodar as consultas._
