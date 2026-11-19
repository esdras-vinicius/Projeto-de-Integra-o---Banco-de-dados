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
* **Jupyter Notebook (VS Code):** Ambiente usado para o desenvolvimento, a execução e a documentação interativa dos notebooks de ETL e ELT, rodando localmente na máquina de cada integrante, junto com o PostgreSQL.
* **SQL & Banco de Dados Relacional (PostgreSQL):** Utilizado para armazenar tanto as tabelas sujas (*Staging*) quanto as tabelas limpas finais (**Data Warehouse**), além de executar toda a lógica de limpeza e transformação via SQL no pipeline **ELT**.
* **Git & GitHub:** Controle de versão distribuído para rastreabilidade das entregas individuais de cada integrante e centralização do código e relatórios.

---

## Base de Dados e Modelagem Dimensional

* **Fonte:** [Série Histórica de Preços de Combustíveis - ANP](https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis) (arquivos semestrais de `2018-01` a `2020-02`).
* **Arquitetura do Data Warehouse (Tabelas Limpas em Esquema Estrela):**
  * **`fato_preco` (Tabela Fato):** Grão de um preço por data, posto e produto. Contém a métrica `valor_venda`, a flag de qualidade `fl_outlier`, o `arquivo_origem` de cada registro e as chaves estrangeiras para as dimensões (`sk_tempo`, `sk_posto`, `sk_produto`, `sk_bandeira`, `sk_localizacao`).
  * **`dim_tempo` (Dimensão):** Data da coleta, ano, semestre, trimestre, mês e classificação do período histórico (*Pré-Greve 2018*, *Greve Caminhoneiros 2018*, *Normalidade 2018-2019* e *Pandemia 2020*).
  * **`dim_produto` (Dimensão):** Tipo de combustível (Gasolina, Gasolina Aditivada, Etanol, Diesel, Diesel S10 e GNV) e unidade de medida (R$/litro ou R$/m³ no GNV).
  * **`dim_localizacao` (Dimensão):** Região, Unidade Federativa (UF) e Município.
  * **`dim_posto` (Dimensão):** CNPJ da revenda, razão social, endereço (rua, número e bairro) e CEP, com o cadastro mais recente de cada posto.
  * **`dim_bandeira` (Dimensão):** Bandeira original, bandeira padronizada (após o de/para) e indicador de posto sem bandeira (`fl_branca`). Fica ligada à fato, porque um posto pode trocar de bandeira ao longo do tempo.

---

## Disposição de Diretórios
```text
Projeto-de-Integra-o---Banco-de-dados/
├── analysis/                          # Scripts SQL com as análises finais (Insights)
│   └── preco_por_periodo_historico.sql/
│   └── cidades_gasolina_mais_cara_e_barata.sql/
│   └── postos_por_bandeira.sql/
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

## Como Executar o Projeto

O projeto roda localmente: os notebooks (Jupyter) e o banco (PostgreSQL) ficam na sua máquina. A ordem é sempre **ETL primeiro, depois ELT**, e no fim a comparação entre os dois.

### 1. Instalar os programas

1. **Python 3.10 ou mais novo** (no Windows, marque "Add Python to PATH" na instalação).
2. **PostgreSQL** (versão 14 ou mais nova). Na instalação, anote a senha que você escolher para o usuário `postgres`.
3. **VS Code**, com as extensões **Python** e **Jupyter** (aba Extensões, `Ctrl+Shift+X`).
4. **Git**, para clonar o repositório.

### 2. Baixar o projeto e instalar as bibliotecas

Abra um terminal (no Windows, o **PowerShell**) e rode:

```bash
git clone https://github.com/esdras-vinicius/Projeto-de-Integra-o---Banco-de-dados.git
cd Projeto-de-Integra-o---Banco-de-dados
python -m venv .venv
```

Ative o ambiente virtual:

```bash
# Windows (PowerShell)
.venv\Scripts\activate
# Mac / Linux
source .venv/bin/activate
```

E instale as bibliotecas (pandas, SQLAlchemy, psycopg2, dbt, Jupyter):

```bash
pip install -r requirements.txt
```

### 3. Criar o banco vazio

```bash
# Windows (troque 18 pela sua versão do PostgreSQL)
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -c "CREATE DATABASE anp_dw;"
# Mac / Linux
psql -U postgres -h localhost -c "CREATE DATABASE anp_dw;"
```

### 4. Informar a conexão com o banco

Os notebooks leem a conexão de **variáveis de ambiente**. Defina-as no mesmo terminal do passo 2 (com o `.venv` ativo), trocando `sua_senha` pela senha do PostgreSQL:

```bash
# Windows (PowerShell)
$env:PGHOST="localhost"; $env:PGPORT="5432"; $env:PGDATABASE="anp_dw"; $env:PGUSER="postgres"; $env:PGPASSWORD="sua_senha"
# Mac / Linux
export PGHOST=localhost PGPORT=5432 PGDATABASE=anp_dw PGUSER=postgres PGPASSWORD=sua_senha
```

Depois abra o VS Code **a partir desse terminal**, para que ele enxergue as variáveis:

```bash
code .
```

> Se o VS Code já estiver aberto, feche-o por completo e abra de novo com `code .`. Variáveis definidas depois que ele abriu não chegam aos notebooks.

O ELT também usa o **dbt**, que tem o próprio arquivo de conexão. Crie o arquivo `profiles.yml` na pasta `.dbt` do seu usuário (Windows: `C:\Users\SEU_USUARIO\.dbt\profiles.yml`; Mac/Linux: `~/.dbt/profiles.yml`) com este conteúdo:

```yaml
transformacao_combustiveis:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: postgres
      password: sua_senha
      dbname: anp_dw
      schema: dw_elt
      threads: 4
```

> Esse arquivo fica fora do repositório, porque tem senha. Não o coloque na pasta do projeto.

### 5. Rodar o ETL

No VS Code, abra `notebooks/ETL.ipynb`. No canto superior direito, em **Select Kernel**, escolha o Python do `.venv`. Depois clique em **Run All**.

O notebook lê os CSVs de `dados/sujo/`, faz toda a limpeza com Pandas e grava o Data Warehouse no schema `dw_etl`. No fim, a seção 12 mostra a tabela fato com **2.686.331 linhas**.

### 6. Rodar o ELT

Abra `notebooks/ELT.ipynb`, escolha o mesmo kernel e clique em **Run All**.

- As seções 1 a 7 carregam os CSVs **sem tratamento** no schema `raw_anp`.
- A seção 8 chama o dbt, que faz a limpeza em SQL dentro do banco e cria o Data Warehouse no schema `dw_elt`. Ela fica alguns minutos sem mostrar nada; é normal.
- A seção 9 compara o tamanho das tabelas dos dois schemas.

Se preferir rodar o dbt pelo terminal (com o `.venv` ativo):

```bash
cd transformacao_combustiveis
dbt build
cd ..
```

O resultado esperado é `PASS=36` (8 modelos e 28 testes).

### 7. Comparar ETL × ELT

Na pasta do projeto, rode:

```bash
# Windows
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -d anp_dw -f sql/02_comparar_etl_elt.sql
# Mac / Linux
psql -U postgres -h localhost -d anp_dw -f sql/02_comparar_etl_elt.sql
```

O resultado esperado é `so_no_etl` e `so_no_elt` iguais a **0** em todas as tabelas: os dois pipelines geram exatamente o mesmo Data Warehouse.

### 8. Rodar as análises

As consultas das análises estão na pasta `analysis/` e rodam do mesmo jeito, por exemplo:

```bash
psql -U postgres -h localhost -d anp_dw -f analysis/preco_por_periodo_historico.sql
```

### Para rodar de novo do zero

O ETL se recusa a gravar em tabelas que já têm dados, para não duplicar linhas. Para recomeçar, apague os schemas e repita a partir do passo 5:

```bash
psql -U postgres -h localhost -d anp_dw -c "DROP SCHEMA IF EXISTS raw_anp, dw_etl, dw_elt CASCADE;"
```

---

## Resultados e Insights
 
As consultas SQL na pasta `/analysis` mostram o que o modelo em estrela permite responder:
 
1. **Preço por período histórico:** A greve teve o preço mais alto, a pandemia o mais baixo.
2. **Cidades mais caras e mais baratas:** R$ 1,36 de diferença por litro.
3. **Postos por bandeira:** o maior grupo é o dos postos sem bandeira.
