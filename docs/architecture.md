# Arquitetura do Projeto

## Modelo Relacional
```
municipios
├── co_ibge (PK)
├── municipio
├── uf
└── regiao
        │
        └──► leitos
             ├── cnes (PK)
             ├── nome_estabelecimento
             ├── co_ibge (FK → municipios)
             ├── co_tipo_unidade (FK → tipos_unidade)
             ├── leitos_existentes
             ├── leitos_sus
             ├── uti_total
             └── tp_gestao
                    ▲
tipos_unidade       │
├── co_tipo_unidade (PK)
└── ds_tipo_unidade
```

## Fluxo de Dados
```
CSV Raw → ingest_sus.py → raw_leitos (Bronze)
                               ↓
              01_create_dimensional_model.sql
                               ↓
         leitos + municipios + tipos_unidade (Silver)
                               ↓
              02_analytical_queries.sql (Gold)
```