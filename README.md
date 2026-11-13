# Projeto de Integração de Dados: Preços de Combustíveis ANP (2018–2020)

Este repositório centraliza o projeto prático de Engenharia e Análise de Dados voltado à construção de um **Data Warehouse** modelado em **Esquema Estrela**. O objetivo é consolidar três anos consecutivos (2018, 2019 e 2020) da Série Histórica de Preços de Combustíveis da **ANP**, aplicando e comparando os paradigmas **ETL** e **ELT**.

## Tecnologias e Ferramentas Utilizadas

* **Python 3 & Pandas:** Utilizados como motor principal no pipeline **ETL** para leitura dos arquivos CSV, tratamento de *encoding* (`ISO-8859-1` / `UTF-8`), limpeza de strings, conversão de tipos numéricos e datas, tratamento de valores nulos, geração de chaves substitutas (*surrogate keys*) e modelagem dimensional em memória.
* **Google Colab:** Ambiente em nuvem utilizado para o desenvolvimento, execução e documentação interativa dos notebooks de ETL e ELT.
* **SQL & Banco de Dados Relacional (PostgreSQL / DuckDB):** *(Nota: ajustar conforme o SGBD final escolhido pelo grupo)* Utilizado para armazenar as tabelas de *Staging* e o **Data Warehouse** final, além de executar toda a lógica de transformação dentro do banco no pipeline **ELT**.
* **Draw.io:** Ferramenta empregada na elaboração dos diagramas de arquitetura do fluxo de dados (ETL vs. ELT) e da modelagem dimensional (Esquema Estrela).
* **Git & GitHub:** Controle de versão distribuído para rastreabilidade das entregas individuais de cada integrante e centralização do código e relatórios.

## Base de Dados e Modelagem Dimensional

* **Fonte:** [Série Histórica de Preços de Combustíveis - ANP](https://www.gov.br/anp/pt-br/centrais-de-conteudo/dados-abertos/serie-historica-de-precos-de-combustiveis) (arquivos semestrais de `2018-01` a `2020-02`).
* **Arquitetura do Data Warehouse (Esquema Estrela):**
  * **`fato_precos` (Tabela Fato):** Métricas de `valor_venda`, `valor_compra`, margem estimada e chaves estrangeiras para as dimensões.
  * **`dim_tempo` (Dimensão):** Data da coleta, ano, semestre, trimestre, mês e classificação do período histórico (ex.: *Pré-Greve*, *Greve 2018*, *Normalidade 2019*, *Pandemia 2020*).
  * **`dim_produto` (Dimensão):** Tipo de combustível (Gasolina Comum, Aditivada, Etanol, Diesel, Diesel S10) e unidade de medida.
  * **`dim_localizacao` (Dimensão):** Região, Unidade Federativa (UF) e Município.
  * **`dim_posto` (Dimensão):** CNPJ da revenda, razão social, bandeira (Branca, Petrobras/Vibra, Ipiranga, Raízen/Shell, etc.), bairro e CEP.

## Disposição de Diretórios

O repositório está estruturado para separar claramente os scripts de ingestão, transformações SQL, diagramas e documentação:

```text
Projeto-de-Integracao-Banco-de-dados/
│
├── data/                       # Instruções de coleta e amostras dos CSVs brutos da ANP (2018–2020)
│   └── README.md                  # Links diretos e orientações de download dos arquivos semestrais
│
├── diagramas/                  # Representações visuais elaboradas no Draw.io
│   ├── fluxo_integracao.drawio    # Arquivo editável do fluxo ETL e ELT
│   ├── fluxo_integracao.png       # Exportação visual da arquitetura
│   ├── esquema_estrela.drawio     # Arquivo editável da modelagem dimensional
│   └── esquema_estrela.png        # Exportação visual do Star Schema
│
├── docs/                       # Documentação e entregas textuais do projeto
│   ├── relatorio_completo.pdf     # Relatório final (Modelagem, ETL vs. ELT, 3 Análises e Reflexões)
│   └── dicionario_dados.md        # Descrição detalhada dos atributos, tipos e metadados do DW
│
├── notebooks/                  # Pipelines desenvolvidos no Google Colab
│   ├── 01_pipeline_etl.ipynb      # Extração, limpeza/transformação com Pandas e carga no DW
│   └── 02_pipeline_elt.ipynb      # Carga bruta (Staging) via Python e transformação via SQL no banco
│
├── sql/                        # Scripts SQL puros para reprodutibilidade
│   ├── 01_ddl_star_schema.sql     # Criação das tabelas Fato e Dimensões
│   ├── 02_transformacoes_elt.sql  # Queries de limpeza, tipagem e carga do ELT
│   └── 03_consultas_insights.sql  # Queries analíticas dos 3 insights apresentados no relatório
│
└── README.md                   # Visão geral do projeto, estrutura e guia de execução
```

## Como Executar o Projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/SEU-USUARIO/Projeto-de-Integracao-Banco-de-dados.git
   ```

2. **Obtenha os dados brutos:**
   * Acesse o portal de Dados Abertos da ANP (indicado em `/data/README.md`) e baixe os 6 arquivos CSV referentes aos semestres de `2018-01` até `2020-02`.

3. **Configure o ambiente no Google Colab:**
   * Faça o upload dos notebooks localizados na pasta `/notebooks` para o Google Colab.
   * Ajuste o caminho de leitura dos arquivos CSV (via Google Drive ou upload direto) e insira as credenciais de conexão com o banco de dados de destino.

4. **Execute os Pipelines:**
   * Rode **`01_pipeline_etl.ipynb`** para acompanhar o tratamento em memória com **Pandas** antes da carga no Data Warehouse.
   * Rode **`02_pipeline_elt.ipynb`** para carregar os dados brutos em tabelas de *staging* e aplicar as transformações via **SQL** diretamente no banco.

5. **Explore os Insights:**
   * Utilize as queries disponíveis em `/sql/03_consultas_insights.sql` para reproduzir as análises sobre a Greve dos Caminhoneiros (2018), a Pandemia (2020) e a variação por bandeira.