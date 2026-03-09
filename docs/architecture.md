# Arquitetura do Projeto

## Modelo Relacional

municipios (co_ibge PK, municipio, uf, regiao)
        │
        └──── leitos (cnes PK, nome_estabelecimento, co_ibge FK, co_tipo_unidade FK,
                      leitos_existentes, leitos_sus, uti_total, tp_gestao)
                             │
tipos_unidade (co_tipo_unidade PK, ds_tipo_unidade)


## Fluxo de Dados

CSV Raw → ingest_sus.py → raw_leitos (Bronze)
                               ↓
          01_create_dimensional_model.sql
                               ↓
     leitos + municipios + tipos_unidade (Silver)
                               ↓
          02_analytical_queries.sql (Gold)


## Decisões de Engenharia

### Por que ELT e não ETL?
Os dados do DATASUS são ingeridos brutos na camada Bronze antes de qualquer
transformação. Isso garante rastreabilidade — se a modelagem Silver tiver um
bug, o dado original está intacto e a reconstrução é possível sem re-download.

### Por que `replace` na camada Bronze?
A tabela `raw_leitos` é sempre recriada a partir do CSV mais recente.
Essa estratégia garante idempotência: rodar o pipeline duas vezes produz o
mesmo resultado, sem duplicação de registros.

### Por que GROUP BY + MAX/SUM na tabela fato?
A base pública do DATASUS contém registros duplicados por CNES.
O `GROUP BY cnes` com `MAX` nos atributos descritivos e `SUM` nos numéricos
resolve a duplicidade sem perda de informação, resultando em
7.369 estabelecimentos únicos.

### Por que DISTINCT nos INSERTs das dimensões?
As dimensões `municipios` e `tipos_unidade` são derivadas da `raw_leitos`.
O `DISTINCT` garante que cada chave primária apareça uma única vez,
evitando violação de constraint na carga.

### Índices e cardinalidade
Antes de criar índices, foi analisada a cardinalidade de cada coluna:
- `cnes`: 7.369 valores únicos → PK, índice implícito
- `co_ibge`: 3.577 valores únicos → alta cardinalidade, índice criado
- `co_tipo_unidade`: 5 valores únicos → baixa, índice desnecessário
- `tp_gestao`: 3 valores únicos → mínima, índice prejudicial

Resultado: índice em `co_ibge` reduziu tempo de query de 8.177ms para 4.544ms.

### SCD Tipo 2 — limitação documentada
Foi implementada a estrutura de SCD Tipo 2 na dimensão `municipios`
(colunas `data_inicio`, `data_fim`, `ativo`). A implementação completa
exige surrogate key — `co_ibge` como PK natural impede múltiplos registros
históricos para o mesmo município. Em produção, o schema precisaria de
refatoração com `sk_municipio SERIAL` como chave substituta.