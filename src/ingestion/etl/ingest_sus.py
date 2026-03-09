import pandas as pd
from sqlalchemy import create_engine, text
import logging
import os
from dotenv import load_dotenv

# Configura onde o log será salvo (na pasta logs)
os.makedirs('logs', exist_ok=True)
logging.basicConfig(
    filename='logs/ingestion.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filemode='a'
)

logging.info("Iniciando processo de ingestão...")

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
load_dotenv(os.path.join(BASE_DIR, 'infra', '.env'))

# Configurações de Conexão
DB_USER = os.getenv("POSTGRES_USER")
DB_PASS = os.getenv("POSTGRES_PASSWORD")
DB_DB   = os.getenv("POSTGRES_DB")
DB_HOST = "localhost"
DB_PORT = "5432"

# Criando a conexão com o banco
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_DB}")

def run_ingestion():
    file_path = os.path.join(BASE_DIR, "data", "raw", "Leitos_2025.csv")
    
    logging.info(f"Iniciando leitura do arquivo: {file_path}")
    
    try:
        # Leitura do CSV
        df = pd.read_csv(file_path, sep=';', encoding='latin1', low_memory=False)
        
        msg_sucesso_leitura = f"Arquivo lido com sucesso! Linhas encontradas: {len(df)}"
        print(f"✅ {msg_sucesso_leitura}")
        logging.info(msg_sucesso_leitura)
        
        # Limpeza Básica de Colunas
        df.columns = [c.lower().replace(' ', '_').replace('.', '') for c in df.columns]

        # Deduplicação por CNES antes do upsert
        df = df.drop_duplicates(subset=['cnes'], keep='last')
        logging.info(f"Registros após deduplicação: {len(df)}")
        
        print("🚀 Enviando dados para o banco Docker...")

        # Carrega CSV completo na camada Bronze (replace)
        with engine.begin() as conn:
            df.to_sql('raw_leitos', conn, if_exists='replace', index=False)
        msg_final = "✅ SUCESSO! Tabela raw_leitos carregada com sucesso."
        print(msg_final)
        logging.info("Carga para o banco de dados finalizada com sucesso.")

    except Exception as e:
        erro_msg = f"ERRO na ingestão: {e}"
        print(f"❌ {erro_msg}")
        logging.error(erro_msg)

if __name__ == "__main__":
    run_ingestion()