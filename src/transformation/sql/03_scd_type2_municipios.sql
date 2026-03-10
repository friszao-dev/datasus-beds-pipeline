-- SCD Tipo 2 - Municipios
-- Preserva histórico de mudanças em atributos da dimensão

-- 1. Adiciona colunas de controle temporal
ALTER TABLE municipios
ADD COLUMN data_inicio DATE,
ADD COLUMN data_fim DATE,
ADD COLUMN ativo BOOLEAN;

-- 2. Inicializa registros existentes como ativos
UPDATE municipios
SET
    data_inicio = CURRENT_DATE,
    data_fim = NULL,
    ativo = TRUE;

-- 3. Simula mudança de região no município de São Paulo (co_ibge = 355030)

-- 3a. Fecha o registro antigo
UPDATE municipios
SET
    data_fim = CURRENT_DATE,
    ativo = FALSE
WHERE
    co_ibge = 355030
    AND ativo = TRUE;

-- 3b. INSERT bloqueado por constraint de PK
-- co_ibge é chave primária natural — não permite duplicidade de registros
-- Em produção, SCD Tipo 2 exige surrogate key (ex: sk_municipio SERIAL)
-- para que o mesmo co_ibge possa ter múltiplos registros históricos.
-- Refatoração do schema seria necessária para implementação completa.

-- 4. Valida registro fechado
SELECT
    co_ibge,
    municipio,
    regiao,
    data_inicio,
    data_fim,
    ativo
FROM municipios
WHERE co_ibge = 355030;
