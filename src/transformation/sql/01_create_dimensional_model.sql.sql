-- Criação das dimensões e tabela fato a partir da raw_leitos

-- 1. Dimensão Municípios
CREATE TABLE municipios (
    co_ibge       INTEGER PRIMARY KEY,
    municipio     VARCHAR(100),
    uf            CHAR(2),
    regiao        VARCHAR(20)
);

-- 2. Dimensão Tipos de Unidade
CREATE TABLE tipos_unidade (
    co_tipo_unidade  INTEGER PRIMARY KEY,
    ds_tipo_unidade  VARCHAR(100)
);

-- 3. Tabela Fato Leitos (normalizada com chaves estrangeiras)
CREATE TABLE leitos (
    cnes                  INTEGER PRIMARY KEY,
    nome_estabelecimento  VARCHAR(200),
    co_ibge               INTEGER REFERENCES municipios(co_ibge),
    co_tipo_unidade       INTEGER REFERENCES tipos_unidade(co_tipo_unidade),
    leitos_existentes     INTEGER,
    leitos_sus            INTEGER,
    uti_total             INTEGER,
    tp_gestao             CHAR(1)
);

-- POPULAÇÃO DAS TABELAS

-- Populando Municípios (DISTINCT para evitar duplicidade)
INSERT INTO municipios (co_ibge, municipio, uf, regiao)
SELECT DISTINCT co_ibge, municipio, uf, regiao
FROM raw_leitos;

-- Populando Tipos de Unidade
INSERT INTO tipos_unidade (co_tipo_unidade, ds_tipo_unidade)
SELECT DISTINCT co_tipo_unidade, ds_tipo_unidade
FROM raw_leitos;

-- Populando Fato Leitos
-- MAX/SUM usados para deduplicar registros com mesmo CNES
INSERT INTO leitos (
    cnes, nome_estabelecimento, co_ibge, co_tipo_unidade,
    leitos_existentes, leitos_sus, uti_total, tp_gestao
)
SELECT
    cnes,
    MAX(nome_estabelecimento),
    MAX(co_ibge),
    MAX(co_tipo_unidade),
    SUM(leitos_existentes),
    SUM(leitos_sus),
    SUM(uti_total_exist),
    MAX(tp_gestao)
FROM raw_leitos
GROUP BY cnes;