-- Criando a Camada Silver: Dados limpos e com métricas prontas
CREATE OR REPLACE VIEW vw_refined_leitos AS
WITH base_calculada AS (
    SELECT 
        nome_estabelecimento,
        uf,
        municipio,
        ds_tipo_unidade,
        tp_gestao,
        leitos_existentes,
        leitos_sus,
        -- Tratando nulos e garantindo que UTIs são números
        COALESCE(uti_total_exist, 0) AS uti_total,
        -- Cálculo de Leitos Privados (tua lógica do script 11)
        (leitos_existentes - leitos_sus) AS leitos_privados,
        -- Indicador de Performance (tua lógica do script 12)
        ROUND(leitos_sus * 100.0 / NULLIF(leitos_existentes, 0), 2) AS percentual_sus
    FROM raw_leitos
    WHERE motivo_desabilitacao IS NULL -- Apenas unidades ativas
)
SELECT 
    *,
    -- Ranking de UTIs por UF (tua lógica do script 14)
    RANK() OVER (PARTITION BY uf ORDER BY uti_total DESC) AS ranking_uti_uf
FROM base_calculada;