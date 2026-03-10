-- ==========================================================
-- NÍVEL 1: FILTROS E BUSCAS BÁSICAS (where / LIKE)
-- ==========================================================

-- 1. Ver apenas hospitais de um estado específico (SP)
SELECT
    uf,
    nome_estabelecimento
FROM raw_leitos
WHERE uf = 'SP';

-- 2. Filtro numérico: Hospitais com mais de 10 leitos de UTI Adulto SUS
SELECT
    nome_estabelecimento,
    uti_adulto_sus
FROM raw_leitos
WHERE uti_adulto_sus > 10;

-- 3. Busca por texto: Listar hospitais que tenham 'MATERNIDADE' no nome
SELECT nome_estabelecimento FROM raw_leitos
WHERE nome_estabelecimento LIKE '%MATERNIDADE%';

-- 4. Filtro composto: Hospitais no RJ com mais de 5 leitos de UTI Pediátrica
SELECT
    nome_estabelecimento,
    uti_pediatrico_sus,
    uf
FROM raw_leitos
WHERE uf = 'RJ' AND uti_pediatrico_sus > 5;


-- ==========================================================
-- NÍVEL 2: AGREGAÇÕES E ESTATÍSTICAS (sum / COUNT / AVG)
-- ==========================================================

-- 5. Soma total nacional: O volume total de leitos no Brasil
SELECT sum(leitos_existentes) AS total_brasil FROM raw_leitos;

-- 6. Contagem de registros: Quantidade de hospitais por estado
SELECT
    uf,
    count(*) AS total_hospitais
FROM raw_leitos
GROUP BY uf
ORDER BY total_hospitais DESC;

-- 7. Soma por grupo: Total de leitos por estado (Ordenado do maior para o menor)
SELECT
    uf,
    sum(leitos_existentes) AS total_leitos
FROM raw_leitos
GROUP BY uf
ORDER BY total_leitos DESC;

-- 8. Média Arredondada: Média de leitos SUS por estado (1 casa decimal)
SELECT
    uf,
    round(avg(leitos_sus), 1) AS media_leitos
FROM raw_leitos
GROUP BY uf;


-- ==============================================================
-- NÍVEL 3: FILTROS DE GRUPO E MÉTRICAS COMPLEXAS (HAVING / MATH)
-- ==============================================================

-- 9. Filtro após agregação (HAVING): Estados com mais de 100.000 leitos no total
SELECT
    uf,
    sum(leitos_existentes) AS total
FROM raw_leitos
GROUP BY uf
HAVING sum(leitos_existentes) > 100000
ORDER BY total DESC;

-- 10. Média com filtro de grupo: Estados com média de UTI maior que 15
SELECT
    uf,
    round(avg(uti_total_exist), 2) AS media
FROM raw_leitos
GROUP BY uf
HAVING avg(uti_total_exist) > 15
ORDER BY media DESC;

-- 11. Cálculo entre colunas: Top 10 hospitais privados de SP (Soma de diferença)
SELECT
    nome_estabelecimento,
    sum(leitos_existentes - leitos_sus) AS leitos_privados
FROM raw_leitos
WHERE uf = 'SP'
GROUP BY nome_estabelecimento
ORDER BY leitos_privados DESC
LIMIT 10;

-- 12. Indicador de Performance: Porcentagem de leitos privados (O "Mestre das Peças")
SELECT
    nome_estabelecimento,
    round(sum(leitos_existentes - leitos_sus) * 100.0 / sum(leitos_existentes), 2) AS percentual_privado
FROM raw_leitos
WHERE leitos_existentes > 0
GROUP BY nome_estabelecimento
ORDER BY percentual_privado DESC
LIMIT 10;


-- 13. Estados com alta densidade hospitalar (>1000 unidades) e sua capacidade média
SELECT
    uf,
    count(*) AS total_estabelecimentos,
    round(avg(leitos_existentes), 0) AS media_leitos_unidade
FROM raw_leitos
GROUP BY uf
HAVING count(*) > 1000
ORDER BY total_estabelecimentos DESC;

-- ==========================================================
-- NÍVEL 4: CTE (COMMON TABLE EXPRESSIONS)
-- ==========================================================

-- 14. Ranking dos 3 maiores hospitais por número de UTIs em cada UF
WITH ranking_uti AS (
    SELECT
        uf,
        nome_estabelecimento,
        uti_total_exist,
        row_number() OVER (PARTITION BY uf ORDER BY uti_total_exist DESC) AS posicao
    FROM raw_leitos
    WHERE uti_total_exist > 0 -- Apenas quem tem UTI
)

SELECT
    uf,
    nome_estabelecimento,
    uti_total_exist,
    posicao
FROM ranking_uti
WHERE posicao <= 3 -- Filtra apenas o Top 3 de cada estado
ORDER BY uf, posicao;
