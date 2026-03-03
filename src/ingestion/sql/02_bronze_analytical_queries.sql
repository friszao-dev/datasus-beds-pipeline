-- ==========================================================
-- NÍVEL 1: FILTROS E BUSCAS BÁSICAS (WHERE / LIKE)
-- ==========================================================

-- 1. Ver apenas hospitais de um estado específico (SP)
select uf, nome_estabelecimento from public.raw_leitos
where uf = 'SP';

-- 2. Filtro numérico: Hospitais com mais de 10 leitos de UTI Adulto SUS
select nome_estabelecimento, uti_adulto_sus from raw_leitos
where uti_adulto_sus > 10;

-- 3. Busca por texto: Listar hospitais que tenham 'MATERNIDADE' no nome
select nome_estabelecimento from raw_leitos
where nome_estabelecimento like '%MATERNIDADE%';

-- 4. Filtro composto: Hospitais no RJ com mais de 5 leitos de UTI Pediátrica
select nome_estabelecimento, uti_pediatrico_sus, uf from raw_leitos 
where uf = 'RJ' and uti_pediatrico_sus > 5;


-- ==========================================================
-- NÍVEL 2: AGREGAÇÕES E ESTATÍSTICAS (SUM / COUNT / AVG)
-- ==========================================================

-- 5. Soma total nacional: O volume total de leitos no Brasil
select SUM(leitos_existentes) as total_brasil from raw_leitos;

-- 6. Contagem de registros: Quantidade de hospitais por estado
select uf, count(*) as total_hospitais 
from raw_leitos 
group by uf 
order by 2 desc;

-- 7. Soma por grupo: Total de leitos por estado (Ordenado do maior para o menor)
select uf, SUM(leitos_existentes) as total_leitos
from raw_leitos
group by uf
order by 2 desc;

-- 8. Média Arredondada: Média de leitos SUS por estado (1 casa decimal)
select uf, round(avg(leitos_sus), 1) as media_leitos 
from raw_leitos 
group by uf;


-- ==============================================================
-- NÍVEL 3: FILTROS DE GRUPO E MÉTRICAS COMPLEXAS (HAVING / MATH)
-- ==============================================================

-- 9. Filtro após agregação (HAVING): Estados com mais de 100.000 leitos no total
select uf, sum(leitos_existentes) as total
from raw_leitos
group by uf
having sum(leitos_existentes) > 100000
order by total desc;

-- 10. Média com filtro de grupo: Estados com média de UTI maior que 15
select uf, round(avg(uti_total_exist), 2) as media 
from raw_leitos
group by uf
having avg(uti_total_exist) > 15
order by media desc;

-- 11. Cálculo entre colunas: Top 10 hospitais privados de SP (Soma de diferença)
select nome_estabelecimento, sum(leitos_existentes - leitos_sus) as leitos_privados
from raw_leitos
where uf = 'SP'
group by nome_estabelecimento
order by leitos_privados desc
limit 10;

-- 12. Indicador de Performance: Porcentagem de leitos privados (O "Mestre das Peças")
select nome_estabelecimento, 
	round(sum(leitos_existentes - leitos_sus) * 100.0 / sum(leitos_existentes), 2) as percentual_privado
from raw_leitos
where leitos_existentes > 0
group by nome_estabelecimento
order by percentual_privado desc
limit 10;


-- 13. Estados com alta densidade hospitalar (>1000 unidades) e sua capacidade média
select uf, count(*) as total_estabelecimentos,
round(avg(leitos_existentes), 0) as media_leitos_unidade
from raw_leitos
group by uf
having count(*) > 1000
order by total_estabelecimentos desc;

-- ==========================================================
-- NÍVEL 4: CTE (COMMON TABLE EXPRESSIONS)
-- ==========================================================

-- 14. Ranking dos 3 maiores hospitais por número de UTIs em cada UF
WITH ranking_uti AS (
    SELECT 
        uf, 
        nome_estabelecimento, 
        uti_total_exist,
        ROW_NUMBER() OVER(PARTITION BY uf ORDER BY uti_total_exist DESC) as posicao
    FROM public.leitos
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