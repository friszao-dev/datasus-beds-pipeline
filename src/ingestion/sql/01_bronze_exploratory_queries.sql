-- 1. Distribuição de Leitos por Tipo de Gestão
select tp_gestao, sum(leitos_existentes) AS total_leitos
from raw_leitos
group by tp_gestao
order by total_leitos desc;


-- 2. Percentual de Leitos SUS vs Total

-- Visão geral (Brasil todo)
select sum(leitos_existentes) AS total_leitos, sum(leitos_sus) AS total_leitos_sus,
round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0),2) AS percentual_sus
from raw_leitos;

-- Visão por estado
select uf, sum(leitos_existentes) AS total_leitos,
sum(leitos_sus) AS leitos_sus,
round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0),2) AS percentual_sus
from raw_leitos
group by uf
order by percentual_sus desc;

-- Visão por município
select uf, municipio,
sum(leitos_existentes) AS total_leitos, sum(leitos_sus) AS leitos_sus,
round(sum(leitos_sus) * 100.0 / nullif(sum(leitos_existentes), 0), 2) AS percentual_sus
from raw_leitos
group by uf, municipio
order by percentual_sus desc;

-- Percentual de Leitos SUS 
with totais AS (select
sum(leitos_existentes) AS total_leitos,
sum(leitos_sus) AS total_leitos_sus
from raw_leitos)

select total_leitos, total_leitos_sus,
round(total_leitos_sus * 100.0 / nullif(total_leitos, 0), 2) AS percentual_sus
from totais;


-- 3. Identificação de Cidades com Leitos de UTI 

-- Municípios que possuem qualquer tipo de UTI
select DISTINCT
    uf,
    municipio
from raw_leitos
where
    coalesce(uti_total_exist, 0) > 0
    or coalesce(uti_adulto_exist, 0) > 0
    or coalesce(uti_pediatrico_exist, 0) > 0
    or coalesce(uti_neonatal_exist, 0) > 0
    or coalesce(uti_queimado_exist, 0) > 0
    or coalesce(uti_coronariana_exist, 0) > 0
order by uf, municipio;

-- Municípios com quantidade total de UTIs
select uf, municipio,
sum(
	coalesce(uti_total_exist, 0) +
    coalesce(uti_adulto_exist, 0) +
    coalesce(uti_pediatrico_exist, 0) +
    coalesce(uti_neonatal_exist, 0) +
    coalesce(uti_queimado_exist, 0) +
    coalesce(uti_coronariana_exist, 0)
    ) AS total_uti
from raw_leitos
group by uf, municipio
having sum(
	coalesce(uti_total_exist, 0) +
	coalesce(uti_adulto_exist, 0) +
	coalesce(uti_pediatrico_exist, 0) +
	coalesce(uti_neonatal_exist, 0) +
	coalesce(uti_queimado_exist, 0) +
	coalesce(uti_coronariana_exist, 0)
    ) > 0
order by total_uti desc;

