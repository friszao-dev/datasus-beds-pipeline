-- 1. Distribuição de Leitos por Tipo de Gestão
SELECT
    tp_gestao,
    sum(leitos_existentes) AS total_leitos
FROM raw_leitos
GROUP BY tp_gestao
ORDER BY total_leitos DESC;


-- 2. Percentual de Leitos SUS vs Total

-- Visão geral (Brasil todo)
SELECT
    sum(leitos_existentes) AS total_leitos,
    sum(leitos_sus) AS total_leitos_sus,
    round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0), 2) AS percentual_sus
FROM raw_leitos;

-- Visão por estado
SELECT
    uf,
    sum(leitos_existentes) AS total_leitos,
    sum(leitos_sus) AS leitos_sus,
    round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0), 2) AS percentual_sus
FROM raw_leitos
GROUP BY uf
ORDER BY percentual_sus DESC;

-- Visão por município
SELECT
    uf,
    municipio,
    sum(leitos_existentes) AS total_leitos,
    sum(leitos_sus) AS leitos_sus,
    round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0), 2) AS percentual_sus
FROM raw_leitos
GROUP BY uf, municipio
ORDER BY percentual_sus DESC;

-- Percentual de Leitos SUS 
WITH totais AS (
    SELECT
        sum(leitos_existentes) AS total_leitos,
        sum(leitos_sus) AS total_leitos_sus
    FROM raw_leitos
)

SELECT
    total_leitos,
    total_leitos_sus,
    round(total_leitos_sus * 100.0 / nullif(total_leitos, 0), 2) AS percentual_sus
FROM totais;


-- 3. Identificação de Cidades com Leitos de UTI 

-- Municípios que possuem qualquer tipo de UTI
SELECT DISTINCT
    uf,
    municipio
FROM raw_leitos
WHERE
    coalesce(uti_total_exist, 0) > 0
    OR coalesce(uti_adulto_exist, 0) > 0
    OR coalesce(uti_pediatrico_exist, 0) > 0
    OR coalesce(uti_neonatal_exist, 0) > 0
    OR coalesce(uti_queimado_exist, 0) > 0
    OR coalesce(uti_coronariana_exist, 0) > 0
ORDER BY uf, municipio;

-- Municípios com quantidade total de UTIs
SELECT
    uf,
    municipio,
    sum(
        coalesce(uti_total_exist, 0)
        + coalesce(uti_adulto_exist, 0)
        + coalesce(uti_pediatrico_exist, 0)
        + coalesce(uti_neonatal_exist, 0)
        + coalesce(uti_queimado_exist, 0)
        + coalesce(uti_coronariana_exist, 0)
    ) AS total_uti
FROM raw_leitos
GROUP BY uf, municipio
HAVING
    sum(
        coalesce(uti_total_exist, 0)
        + coalesce(uti_adulto_exist, 0)
        + coalesce(uti_pediatrico_exist, 0)
        + coalesce(uti_neonatal_exist, 0)
        + coalesce(uti_queimado_exist, 0)
        + coalesce(uti_coronariana_exist, 0)
    ) > 0
ORDER BY total_uti DESC;
