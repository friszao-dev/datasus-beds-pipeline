import pandas as pd
from sqlalchemy import create_engine
import logging
import os
from dotenv import load_dotenv

# Define raiz do projeto
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# Configura log sempre na raiz do projeto
LOG_DIR = os.path.join(BASE_DIR, 'logs')
os.makedirs(LOG_DIR, exist_ok=True)
logging.basicConfig(
    filename=os.path.join(LOG_DIR, 'ingestion.log'),
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filemode='a'
)

logging.info("Iniciando processo de ingestão...")

load_dotenv(os.path.join(BASE_DIR, 'infra', '.env'))

# Configurações de Conexão
DB_USER = os.getenv("POSTGRES_USER")
DB_PASS = os.getenv("POSTGRES_PASSWORD")
DB_DB = os.getenv("POSTGRES_DB")
DB_HOST = "localhost"
DB_PORT = "5432"

# Criando a conexão com o banco
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_DB}")


def run_ingestion():
    file_path = os.path.join(BASE_DIR, "data", "raw", "Leitos_2025.csv")

    logging.info(f"Iniciando leitura do arquivo: {file_path}")

    try:
        df = pd.read_csv(file_path, sep=';', encoding='latin1', low_memory=False)

        print(f"✅ Arquivo lido com sucesso! Linhas encontradas: {len(df)}")
        logging.info(f"Arquivo lido com sucesso! Linhas encontradas: {len(df)}")

        df.columns = [c.lower().replace(' ', '_').replace('.', '') for c in df.columns]

        df = df.drop_duplicates(subset=['cnes'], keep='last')
        logging.info(f"Registros após deduplicação: {len(df)}")

        print("🚀 Enviando dados para o banco Docker...")

        with engine.begin() as conn:
            df.to_sql('raw_leitos', conn, if_exists='replace', index=False)

        print("✅ SUCESSO! Tabela raw_leitos carregada com sucesso.")
        logging.info("Carga para o banco de dados finalizada com sucesso.")

    except Exception as e:
        erro_msg = f"ERRO na ingestão: {e}"
        print(f"❌ {erro_msg}")
        logging.error(erro_msg)


if __name__ == "__main__":
    run_ingestion()
