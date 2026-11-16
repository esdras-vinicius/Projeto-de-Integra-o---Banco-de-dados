-- Esquema produzido pelo notebook ETL.
-- Os nomes das colunas correspondem aos DataFrames criados em ETL.ipynb.
-- O SQL pode ser executado novamente: CREATE ... IF NOT EXISTS preserva tabelas existentes.

CREATE SCHEMA IF NOT EXISTS dw_etl;

-- Uma linha por dia entre 2018-01-01 e 2020-12-31.
CREATE TABLE IF NOT EXISTS dw_etl.dim_tempo (
    sk_tempo INTEGER PRIMARY KEY,
    data DATE NOT NULL UNIQUE,
    dia SMALLINT NOT NULL,
    mes SMALLINT NOT NULL,
    nome_mes TEXT NOT NULL,
    trimestre SMALLINT NOT NULL,
    semestre SMALLINT NOT NULL,
    ano SMALLINT NOT NULL,
    dia_semana TEXT NOT NULL,
    periodo_historico TEXT NOT NULL
);

-- Um posto por CNPJ na versão atual da modelagem.
-- A célula que monta esta dimensão escolhe o cadastro mais recente do CNPJ.
CREATE TABLE IF NOT EXISTS dw_etl.dim_posto (
    sk_posto INTEGER PRIMARY KEY,
    cnpj CHAR(14) NOT NULL UNIQUE,
    razao_social TEXT NOT NULL,
    rua TEXT,
    numero_rua TEXT,
    complemento TEXT,
    bairro TEXT,
    cep CHAR(8)
);

CREATE TABLE IF NOT EXISTS dw_etl.dim_localizacao (
    sk_localizacao INTEGER PRIMARY KEY,
    regiao TEXT NOT NULL,
    uf CHAR(2) NOT NULL,
    municipio TEXT NOT NULL,
    UNIQUE (regiao, uf, municipio)
);

CREATE TABLE IF NOT EXISTS dw_etl.dim_produto (
    sk_produto INTEGER PRIMARY KEY,
    produto TEXT NOT NULL,
    unidade_medida TEXT NOT NULL,
    UNIQUE (produto, unidade_medida)
);

-- A bandeira observada em cada coleta fica associada diretamente à fato.
CREATE TABLE IF NOT EXISTS dw_etl.dim_bandeira (
    sk_bandeira INTEGER PRIMARY KEY,
    bandeira_original TEXT NOT NULL,
    bandeira_padronizada TEXT NOT NULL,
    fl_branca BOOLEAN NOT NULL,
    UNIQUE (bandeira_original, bandeira_padronizada)
);

-- Grão adotado: um preço por data, posto e produto.
-- Valor de compra e margem admitem NULL quando a ANP não informou compra.
CREATE TABLE IF NOT EXISTS dw_etl.fato_preco (
    id_preco BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sk_tempo INTEGER NOT NULL REFERENCES dw_etl.dim_tempo (sk_tempo),
    sk_posto INTEGER NOT NULL REFERENCES dw_etl.dim_posto (sk_posto),
    sk_produto INTEGER NOT NULL REFERENCES dw_etl.dim_produto (sk_produto),
    sk_bandeira INTEGER NOT NULL REFERENCES dw_etl.dim_bandeira (sk_bandeira),
    sk_localizacao INTEGER NOT NULL REFERENCES dw_etl.dim_localizacao (sk_localizacao),
    valor_venda NUMERIC(12, 4) NOT NULL CHECK (valor_venda > 0),
    valor_compra NUMERIC(12, 4),
    margem NUMERIC(12, 4),
    fl_compra_maior_venda BOOLEAN NOT NULL,
    fl_outlier BOOLEAN NOT NULL,
    arquivo_origem TEXT NOT NULL,
    UNIQUE (sk_tempo, sk_posto, sk_produto)
);
