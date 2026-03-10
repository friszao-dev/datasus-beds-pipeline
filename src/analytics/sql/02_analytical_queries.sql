/* QUERIES ANALÍTICAS - DATASUS LEITOS */


-- 1. Contagem total de estabelecimentos
SELECT COUNT(*) FROM leitos;

-- 2. Estabelecimentos com mais de 10 leitos de UTI
SELECT
    nome_estabelecimento,
    cnes
FROM leitos
WHERE uti_total > 10;

-- 3. Municípios da região Sudeste
SELECT
    municipio,
    uf,
    regiao
FROM municipios
WHERE regiao = 'SUDESTE'
ORDER BY municipio;

-- 4. Tipos de unidade em ordem alfabética
SELECT *
FROM tipos_unidade
ORDER BY ds_tipo_unidade;


-- 5. Total de leitos SUS na base
SELECT SUM(leitos_sus) AS total_leitos_sus
FROM leitos;

-- 6. Média de leitos existentes por estabelecimento
SELECT ROUND(AVG(leitos_existentes), 2) AS media_capacidade
FROM leitos;

-- 7. Quantidade de estabelecimentos por tipo de gestão
SELECT
    tp_gestao,
    COUNT(*) AS qtd_estabelecimentos
FROM leitos
GROUP BY tp_gestao;


-- 8. Nome do estabelecimento e descrição do tipo de unidade
SELECT
    l.nome_estabelecimento,
    t.ds_tipo_unidade
FROM leitos AS l
INNER JOIN tipos_unidade AS t ON l.co_tipo_unidade = t.co_tipo_unidade;

-- 9. Total de leitos UTI por região (JOIN + GROUP BY)
SELECT
    m.regiao,
    SUM(l.uti_total) AS total_uti
FROM leitos AS l
INNER JOIN municipios AS m ON l.co_ibge = m.co_ibge
GROUP BY m.regiao
ORDER BY total_uti DESC;

-- 10. Ranking das 5 cidades com mais leitos SUS 
SELECT
    m.municipio,
    m.uf,
    SUM(l.leitos_sus) AS total_leitos_sus,
    RANK() OVER (ORDER BY SUM(l.leitos_sus) DESC) AS ranking
FROM leitos AS l
INNER JOIN municipios AS m ON l.co_ibge = m.co_ibge
GROUP BY m.municipio, m.uf
ORDER BY total_leitos_sus DESC
LIMIT 5;


-- CONFERÊNCIA DE INTEGRIDADE ============================================================

-- Valida se total de CNES únicos na raw bate com a fato
SELECT COUNT(DISTINCT cnes) FROM raw_leitos;
SELECT COUNT(*) FROM leitos;

-- Verifica duplicidade na fato (deve retornar vazio)
SELECT
    cnes,
    COUNT(*) AS total
FROM leitos
GROUP BY cnes
HAVING COUNT(*) > 1;


-- =======================
-- ANÁLISE DE PERFORMANCE
-- =======================

-- Índice criado para otimizar join e filtros por co_ibge
-- CREATE INDEX idx_leitos_co_ibge ON leitos(co_ibge);

-- Resultado observado:
-- Seq Scan: usado quando query retorna todos os registros (co_ibge > 1)
-- Bitmap Index Scan: usado quando filtro é seletivo (co_ibge = 355030)
-- Redução de tempo com índice: 8.177ms > 4.544ms na query analítica


-- Análise de cardinalidade para decisão de índices
-- Alta cardinalidade = bom candidato a índice
-- Baixa cardinalidade = índice inútil, banco fará Seq Scan de qualquer forma
SELECT
    COUNT(DISTINCT cnes) AS card_cnes,           -- 7369 = cardinalidade máxima (PK)
    COUNT(DISTINCT co_ibge) AS card_co_ibge,        -- 3577 = alta, índice criado
    COUNT(DISTINCT co_tipo_unidade) AS card_tipo_unidade,   -- 5 = baixa, índice desnecessário
    COUNT(DISTINCT tp_gestao) AS card_tp_gestao,      -- 3 = mínima, índice prejudicial
    COUNT(*) AS total_registros      -- 7369
FROM leitos;
