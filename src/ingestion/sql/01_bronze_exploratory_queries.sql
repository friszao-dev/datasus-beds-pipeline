-- 1. Distribuição de Leitos por Tipo de Gestão (Estadual, Municipal, etc.)
select tp_gestao, SUM(leitos_existentes) AS total_leitos
FROM raw_leitos
GROUP BY tp_gestao
ORDER BY total_leitos DESC;


-- 2. Percentual de Leitos SUS vs Total (Visão de Eficiência)

-- Visão geral (Brasil todo)
select SUM(leitos_existentes) AS total_leitos, SUM(leitos_sus) AS total_leitos_sus,
ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0),2) AS percentual_sus
FROM raw_leitos;

-- Visão por estado
select uf, SUM(leitos_existentes) AS total_leitos,
SUM(leitos_sus) AS leitos_sus,
ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0),2) AS percentual_sus
FROM raw_leitos
GROUP BY uf
ORDER BY percentual_sus desc;

-- Visão por município
select uf, municipio,
SUM(leitos_existentes) AS total_leitos, SUM(leitos_sus) AS leitos_sus,
ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS percentual_sus
FROM raw_leitos
GROUP BY uf, municipio
ORDER BY percentual_sus DESC;

-- Percentual de Leitos SUS utilizando WITH
WITH totais AS (SELECT
SUM(leitos_existentes) AS total_leitos,
SUM(leitos_sus) AS total_leitos_sus
FROM raw_leitos)

select total_leitos, total_leitos_sus,
ROUND(total_leitos_sus * 100.0 / NULLIF(total_leitos, 0), 2) AS percentual_sus
FROM totais;


-- 3. Identificação de Cidades com Leitos de UTI (Filtro Crítico)

-- Municípios que possuem qualquer tipo de UTI
SELECT DISTINCT
    uf,
    municipio
FROM raw_leitos
WHERE
    COALESCE(uti_total_exist, 0) > 0
    OR COALESCE(uti_adulto_exist, 0) > 0
    OR COALESCE(uti_pediatrico_exist, 0) > 0
    OR COALESCE(uti_neonatal_exist, 0) > 0
    OR COALESCE(uti_queimado_exist, 0) > 0
    OR COALESCE(uti_coronariana_exist, 0) > 0
ORDER BY uf, municipio;

-- Municípios com quantidade total de UTIs
select uf, municipio,
SUM(
	COALESCE(uti_total_exist, 0) +
    COALESCE(uti_adulto_exist, 0) +
    COALESCE(uti_pediatrico_exist, 0) +
    COALESCE(uti_neonatal_exist, 0) +
    COALESCE(uti_queimado_exist, 0) +
    COALESCE(uti_coronariana_exist, 0)
    ) AS total_uti
FROM raw_leitos
GROUP BY uf, municipio
HAVING SUM(
	COALESCE(uti_total_exist, 0) +
	COALESCE(uti_adulto_exist, 0) +
	COALESCE(uti_pediatrico_exist, 0) +
	COALESCE(uti_neonatal_exist, 0) +
	COALESCE(uti_queimado_exist, 0) +
	COALESCE(uti_coronariana_exist, 0)
    ) > 0
ORDER BY total_uti DESC;

