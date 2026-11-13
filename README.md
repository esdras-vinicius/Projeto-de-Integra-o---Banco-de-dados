# Projeto de Integração de Dados: Preços de Combustíveis ANP (2018–2020)

Este repositório centraliza o projeto prático de Engenharia e Análise de Dados voltado à construção de um **Data Warehouse** modelado em **Esquema Estrela**. O objetivo é consolidar três anos consecutivos (2018, 2019 e 2020) da Série Histórica de Preços de Combustíveis da **ANP**, aplicando e comparando os paradigmas **ETL** e **ELT** a partir do tratamento de tabelas sujas para tabelas limpas.

## Estratégia de Dados: Tabelas Sujas e Tabelas Limpas

O fluxo de integração do projeto organiza os dados em duas camadas principais de maturidade:

* **Tabelas Sujas (Camada Bruta / *Staging*):** Correspondem aos dados originais extraídos diretamente dos arquivos CSV da ANP (`ca-2018-01.csv` a `ca-2020-02.csv`), sem alterações estruturais. Essa camada preserva inconsistências reais da fonte, como delimitadores por ponto e vírgula (`;`), valores decimais com vírgula, variações de *encoding* (`ISO-8859-1` / `UTF-8`), registros duplicados e ausência de colunas (como o `Valor de Compra` no 2º semestre de 2020). No pipeline **ELT**, esses dados são carregados integralmente como tabelas sujas no banco de dados antes da etapa de transformação.
* **Tabelas Limpas (Camada Tratada / *Data Warehouse*):** Representam os dados após higienização, padronização de textos e datas, conversão de tipos numéricos, tratamento de valores nulos e criação de chaves substitutas (*surrogate keys*). No pipeline **ETL**, essa limpeza ocorre em memória via **Pandas** antes da carga; no **ELT**, ocorre via **SQL** dentro do próprio banco de dados, resultando nas tabelas finais do Esquema Estrela.

## Tecnologias e Ferramentas Utilizadas

* **Python 3 & Pandas:** Utilizados como motor principal no pipeline **ETL** para leitura dos CSVs sujos, limpeza de strings, conversão de tipos, tratamento de nulos e modelagem das tabelas limpas em memória.
* **Google Colab:** Ambiente em nuvem utilizado para o desenvolvimento, execução e documentação interativa dos notebooks de ETL e ELT.
* **SQL & Banco de Dados Relacional (PostgreSQL / DuckDB):** Utilizado para armazenar tanto as tabelas sujas (*Staging*) quanto as tabelas limpas finais (**Data Warehouse**), além de executar toda a lógica de limpeza e transformação via SQL no pipeline **ELT**.
* **Draw.io:** Ferramenta empregada na elaboração dos diagramas de arquitetura do fluxo de dados (ETL vs. ELT) e da modelagem dimensional (Esquema Estrela).
* **Git & GitHub:** Controle de versão distribuído para rastreabilidade das entregas individuais de cada integrante e centralização do código e relatórios.

## Base de Dados e Modelagem Dimensional

* **Fonte:** [Série Histórica de Preços de Combustíveis - ANP](https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis) (arquivos semestrais de `2018-01` a `2020-02`).
* **Arquitetura do Data Warehouse (Tabelas Limpas em Esquema Estrela):**
  * **`fato_precos` (Tabela Fato):** Métricas de `valor_venda`, `valor_compra`, margem estimada e chaves estrangeiras para as dimensões.
  * **`dim_tempo` (Dimensão):** Data da coleta, ano, semestre, trimestre, mês e classificação do período histórico (ex.: *Pré-Greve*, *Greve 2018*, *Normalidade 2019*, *Pandemia 2020*).
  * **`dim_produto` (Dimensão):** Tipo de combustível (Gasolina Comum, Aditivada, Etanol, Diesel, Diesel S10) e unidade de medida.
  * **`dim_localizacao` (Dimensão):** Região, Unidade Federativa (UF) e Município.
  * **`dim_posto` (Dimensão):** CNPJ da revenda, razão social, bandeira (Branca, Petrobras/Vibra, Ipiranga, Raízen/Shell, etc.), bairro e CEP.

## Disposição de Diretórios

O repositório está estruturado conforme a organização local do projeto, separando os dados brutos/sujos, os notebooks de processamento, os scripts SQL, os diagramas e a documentação:

```text
Projeto-de-Integra-o---Banco-de-dados/
│
├── dados/                            # Conjuntos de dados do projeto (sujos e limpos)
│   ├── ca-2018-01.csv                # Base bruta (suja) - 1º semestre de 2018
│   ├── ca-2018-02.csv                # Base bruta (suja) - 2º semestre de 2018
│   ├── ca-2019-01.csv                # Base bruta (suja) - 1º semestre de 2019
│   ├── ca-2019-02.csv                # Base bruta (suja) - 2º semestre de 2019
│   ├── ca-2020-01.csv                # Base bruta (suja) - 1º semestre de 2020
│   ├── ca-2020-02.csv                # Base bruta (suja) - 2º semestre de 2020
│   └── limpos/                       # (Opcional) Tabelas limpas exportadas após o tratamento
│
├── diagramas/                        # Representações visuais elaboradas no Draw.io
│   ├── fluxo_integracao.drawio       # Arquivo editável do fluxo ETL e ELT
│   ├── fluxo_integracao.png          # Exportação visual da arquitetura
│   ├── esquema_estrela.drawio        # Arquivo editável da modelagem dimensional
│   └── esquema_estrela.png           # Exportação visual do Star Schema
│
├── docs/                             # Documentação e entregas textuais do projeto
│   ├── relatorio_completo.pdf        # Relatório final (Modelagem, ETL vs. ELT, 3 Análises e Reflexões)
│   └── dicionario_dados.md           # Descrição detalhada das tabelas sujas e limpas do DW
│
├── notebooks/                        # Pipelines desenvolvidos no Google Colab
│   ├── 01_pipeline_etl.ipynb         # Leitura das bases sujas, limpeza com Pandas e carga das tabelas limpas
│   └── 02_pipeline_elt.ipynb         # Carga das tabelas sujas (Staging) e limpeza via SQL no banco
│
├── sql/                              # Scripts SQL puros para reprodutibilidade
│   ├── 01_ddl_tabelas_sujas_e_dw.sql # Criação das tabelas de staging (sujas) e do DW (limpas)
│   ├── 02_transformacoes_elt.sql     # Queries de limpeza, tipagem e carga das tabelas limpas
│   └── 03_consultas_insights.sql     # Queries analíticas dos 3 insights apresentados no relatório
│
└── README.md                         # Visão geral do projeto, estrutura e guia de execução
```

## Como Executar o Projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/SEU-USUARIO/Projeto-de-Integra-o---Banco-de-dados.git
   ```

2. **Verifique os dados na pasta `dados/`:**
   * Os 6 arquivos semestrais brutos (`ca-2018-01.csv` até `ca-2020-02.csv`) servem como entrada para ambos os pipelines.

3. **Configure o ambiente no Google Colab:**
   * Faça o upload dos notebooks localizados na pasta `/notebooks` para o Google Colab.
   * Conecte o Google Drive ou faça o upload dos arquivos da pasta `dados/` e configure a conexão com o banco de dados de destino.

4. **Execute os Pipelines:**
   * Rode **`01_pipeline_etl.ipynb`** para ler as bases sujas, aplicar toda a limpeza em memória com **Pandas** e carregar as tabelas limpas no Data Warehouse.
   * Rode **`02_pipeline_elt.ipynb`** para carregar os CSVs diretamente como tabelas sujas (*staging*) no banco e executar os scripts SQL de limpeza para gerar as tabelas limpas.

5. **Explore os Insights:**
   * Utilize as queries disponíveis em `/sql/03_consultas_insights.sql` sobre as tabelas limpas para reproduzir as análises da Greve dos Caminhoneiros (2018), da Pandemia (2020) e da variação por bandeira.