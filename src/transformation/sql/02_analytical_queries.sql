/* QUERIES ANALÍTICAS - DATASUS LEITOS
Exercícios práticos com JOIN, agregação e window functions */

-- NÍVEL BÁSICO

-- 1. Contagem total de estabelecimentos
SELECT COUNT(*) FROM leitos;

-- 2. Estabelecimentos com mais de 10 leitos de UTI
SELECT nome_estabelecimento, cnes
FROM leitos
WHERE uti_total > 10;

-- 3. Municípios da região Sudeste
SELECT municipio, uf, regiao
FROM municipios
WHERE regiao = 'SUDESTE'
ORDER BY municipio;

-- 4. Tipos de unidade em ordem alfabética
SELECT *
FROM tipos_unidade
ORDER BY ds_tipo_unidade;

-- NÍVEL INTERMEDIÁRIO ============================================================

-- 5. Total de leitos SUS na base
SELECT SUM(leitos_sus) AS total_leitos_sus
FROM leitos;

-- 6. Média de leitos existentes por estabelecimento
SELECT ROUND(AVG(leitos_existentes), 2) AS media_capacidade
FROM leitos;

-- 7. Quantidade de estabelecimentos por tipo de gestão
SELECT tp_gestao, COUNT(*) AS qtd_estabelecimentos
FROM leitos
GROUP BY tp_gestao;

-- NÍVEL AVANÇADO ============================================================

-- 8. Nome do estabelecimento e descrição do tipo de unidade (JOIN)
SELECT l.nome_estabelecimento, t.ds_tipo_unidade
FROM leitos l
JOIN tipos_unidade t ON t.co_tipo_unidade = l.co_tipo_unidade;

-- 9. Total de leitos UTI por região (JOIN + GROUP BY)
SELECT m.regiao, SUM(l.uti_total) AS total_uti
FROM leitos l
JOIN municipios m ON m.co_ibge = l.co_ibge
GROUP BY m.regiao
ORDER BY total_uti DESC;

-- 10. Ranking das 5 cidades com mais leitos SUS (Window Function)
SELECT
    m.municipio,
    m.uf,
    SUM(l.leitos_sus) AS total_leitos_sus,
    RANK() OVER (ORDER BY SUM(l.leitos_sus) DESC) AS ranking
FROM leitos l
JOIN municipios m ON m.co_ibge = l.co_ibge
GROUP BY m.municipio, m.uf
ORDER BY total_leitos_sus DESC
LIMIT 5;


-- CONFERÊNCIA DE INTEGRIDADE ============================================================

-- Valida se total de CNES únicos na raw bate com a fato
SELECT COUNT(DISTINCT cnes) FROM raw_leitos;
SELECT COUNT(*) FROM leitos;

-- Verifica duplicidade na fato (deve retornar vazio)
SELECT cnes, COUNT(*)
FROM leitos
GROUP BY cnes
HAVING COUNT(*) > 1;
