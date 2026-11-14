# Projeto de Integração de Dados: Preços de Combustíveis ANP (2018–2020)

Este repositório centraliza o projeto prático de Engenharia e Análise de Dados voltado à construção de um **Data Warehouse** modelado em **Esquema Estrela**. O objetivo é consolidar três anos consecutivos (2018, 2019 e 2020) da Série Histórica de Preços de Combustíveis da **ANP**, aplicando e comparando os paradigmas **ETL** e **ELT** a partir do tratamento de tabelas sujas para tabelas limpas.

## Estratégia de Dados: Tabelas Sujas e Tabelas Limpas

O fluxo de integração do projeto organiza os dados em duas camadas principais de maturidade:

* **Tabelas Sujas (Camada Bruta / *Staging*):** Correspondem aos dados originais extraídos diretamente dos arquivos CSV da ANP (`dados/sujo/ca-2018-01.csv` a `ca-2020-02.csv`), sem alterações estruturais. Essa camada preserva inconsistências reais da fonte, como delimitadores por ponto e vírgula (`;`), valores decimais com vírgula, variações de *encoding* (`ISO-8859-1` / `UTF-8`), registros duplicados e ausência de colunas (como o `Valor de Compra` no 2º semestre de 2020). No pipeline **ELT**, esses dados são carregados integralmente como tabelas sujas no banco de dados antes da etapa de transformação.
* **Tabelas Limpas (Camada Tratada / *Data Warehouse*):** Representam os dados após higienização, padronização de textos e datas, conversão de tipos numéricos, tratamento de valores nulos e criação de chaves substitutas (*surrogate keys*). No pipeline **ETL**, essa limpeza ocorre em memória via **Pandas** antes da carga; no **ELT**, ocorre via **SQL** dentro do próprio banco de dados, resultando nas tabelas finais do Esquema Estrela.

## Tecnologias e Ferramentas Utilizadas

* **Python 3 & Pandas:** Utilizados como motor principal no pipeline **ETL** para leitura dos CSVs sujos, limpeza de strings, conversão de tipos, tratamento de nulos e modelagem das tabelas limpas em memória.
* **Google Colab:** Ambiente em nuvem utilizado para o desenvolvimento, execução e documentação interativa dos notebooks de ETL e ELT.
* **SQL & Banco de Dados Relacional (PostgreSQL):** Utilizado para armazenar tanto as tabelas sujas (*Staging*) quanto as tabelas limpas finais (**Data Warehouse**), além de executar toda a lógica de limpeza e transformação via SQL no pipeline **ELT**.
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

```text
Projeto-de-Integra-o---Banco-de-dados/
│
├── dados/
│   ├── sujo/                   # Camada bruta: CSVs originais da ANP (ca-2018-01 a ca-2020-02)
│   └── limpo/                  # Tabelas limpas exportadas após o tratamento
├── notebooks/
│   └── ETL.ipynb               # Pipeline ETL: leitura dos CSVs sujos, limpeza com Pandas e carga
├── diagramas/                  # Diagramas (Draw.io): fluxo ETL/ELT e Esquema Estrela
├── requirements.txt            # Dependências (pandas, sqlalchemy, psycopg2-binary, dbt-postgres, jupyter)
├── requirements.lock.txt       # Versões exatas instaladas
├── .gitignore
└── README.md
```

> Planejado e ainda não criado: notebook do ELT, scripts SQL (`sql/`), projeto dbt e documentação (`docs/`).

## Ambiente Virtual

```bash
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt    # ou requirements.lock.txt para as versões exatas
```

O servidor PostgreSQL precisa estar instalado e em execução separadamente.

## Como Executar o Projeto

1. **Prepare o ambiente** conforme a seção anterior.
2. **Dados de entrada:** os 6 CSVs brutos ficam em `dados/sujo/`.
3. **Pipeline ETL:** execute `notebooks/ETL.ipynb` (Jupyter local ou Google Colab) para limpar com Pandas e carregar as tabelas limpas no PostgreSQL.
4. **Pipeline ELT:** carregar os CSVs como tabelas sujas (*staging*) e transformar via SQL/dbt (a implementar).
