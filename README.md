# Data Engineering Health Journey - Pipeline DATASUS

Este repositório documenta a construção de um pipeline de dados focado
no setor de saúde pública brasileira. O objetivo é transformar dados
brutos do DATASUS em informação estruturada e analítica por meio de boas
práticas de engenharia de dados.

------------------------------------------------------------------------

## Problema de Negócio

Os dados públicos do DATASUS são disponibilizados em formato bruto
(CSV), o que dificulta análicas comparativas, padronização de métricas e
análises estratégicas.

Este projeto organiza e modela esses dados para permitir:

-   Análise da distribuição de leitos hospitalares por UF
-   Comparação entre leitos totais e leitos SUS
-   Ranking de especialização hospitalar por estado
-   Consolidação de métricas analíticas reutilizáveis

------------------------------------------------------------------------

## Arquitetura e Estratégia

O projeto adota a filosofia **ELT (Extract, Load, Transform)**,
priorizando a ingestão bruta (RAW) para garantir rastreabilidade e
integridade dos dados antes da modelagem analítica.

### Fluxo de Dados

\[CSV Raw\] → \[Python + Logging\] → \[PostgreSQL - Bronze\] → \[Views
Analíticas - Silver\] → \[Métricas - Gold\]

### Camadas do Projeto

-   **Bronze** → `raw_leitos` (dados originais, sem transformação)
-   **Silver** → `vw_refined_leitos` (padronização, tratamento de nulos,
    métricas calculadas)
-   **Gold** → Rankings e métricas consolidadas para consumo analítico

------------------------------------------------------------------------

## Estrutura do Repositório

    .
    ├── data/
    │   └── raw/
    ├── infra/
    ├── src/
    │   ├── ingestion/      # Camada Bronze (Carga RAW)
    │   ├── transformation/ # Camada Silver (Refino e Views Analíticas)
    │   └── analytics/      # Camada Gold (Dashboards e Data Marts)
    ├── docs/
    └── README.md

------------------------------------------------------------------------

## Tecnologias e Infraestrutura

-   **Linguagem:** Python\
-   **Bibliotecas:** Pandas, SQLAlchemy, python-dotenv, logging\
-   **Banco de Dados:** PostgreSQL 17\
-   **Interface:** pgAdmin 4 / DBeaver\
-   **Orquestração:** Docker Compose\
-   **Persistência:** Volumes Docker\
-   **Versionamento:** Git e GitHub

------------------------------------------------------------------------

## Como Executar o Ambiente

### 1. Configuração de Variáveis de Ambiente

O projeto utiliza um arquivo `.env` para gestão de credenciais.

-   Renomeie `infra/.env.example` para `infra/.env`
-   Ajuste as credenciais conforme necessário

### 2. Pré-requisitos

-   Docker Desktop instalado e rodando
-   Git

### 3. Subindo a Infraestrutura

    cd infra
    docker-compose up -d

### 4. Acesso aos Serviços

-   pgAdmin → http://localhost:8080\
-   PostgreSQL → Porta 5432

------------------------------------------------------------------------

## Validação da Ingestão

Após executar o script de ingestão:

    SELECT COUNT(*) FROM raw_leitos;

Valide se o total corresponde ao número de linhas do CSV original.

Validação da camada refinada:

    SELECT * 
    FROM vw_refined_leitos 
    WHERE ranking_uti_uf <= 3;

------------------------------------------------------------------------

## Roadmap de Desenvolvimento

### Fase 1 -- Infraestrutura (Concluído)

-   Estruturação do repositório
-   Configuração de Docker Compose com persistência via volumes
-   Ambiente virtual isolado (`.venv`) para desenvolvimento Python

### Fase 2 -- Ingestão e Modelagem Inicial (Concluído)

-   Desenvolvimento do script `ingest_sus.py` (Pandas + SQLAlchemy)
-   Carga de 86.147 registros para PostgreSQL
-   Implementação de CTEs e Window Functions para cálculo de métricas
-   Tratamento de nulos com `COALESCE` e prevenção de divisão por zero
    com `NULLIF`
-   Criação de Views analíticas (Camada Silver)
-   Implementação de logging persistente para rastreabilidade

### Fase 3 -- Qualidade e CI/CD (Em progresso)

-   Integração de SQLFluff
-   Automação com GitHub Actions

------------------------------------------------------------------------

## Decisões de Engenharia

### Foco em Resiliência

Testes de reinicialização de containers e validação da persistência via
volumes Docker para garantir integridade dos dados.

### Abordagem RAW First

Os dados não são transformados durante a ingestão para preservar
rastreabilidade e permitir reprocessamento controlado.

------------------------------------------------------------------------

## Próximos Passos

-   Automatizar execução da ingestão
-   Implementar modelagem com dbt
-   Evoluir monitoramento e testes de qualidade de dados

------------------------------------------------------------------------

## Licença

Este projeto está sob a licença MIT.
