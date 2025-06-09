import logging
import os

from pythonjsonlogger import jsonlogger
import psycopg

LOG = logging.getLogger(name=__name__)
LOG.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
streamHandler.setFormatter(
    jsonlogger.JsonFormatter(fmt='%(asctime)s %(levelname)s %(name)s %(message)s'),
)
LOG.addHandler(streamHandler)

def main():
    with open(
        file=os.getenv("ISKPRINTER_POSTGRES_USERNAME_PATH"),
        mode="r",
        encoding="utf-8",
    ) as f:
        postgres_username = f.read().strip()

    with open(
        file=os.getenv("ISKPRINTER_POSTGRES_PASSWORD_PATH"),
        mode="r",
        encoding="utf-8",
    ) as f:
        postgres_password = f.read().strip()

    database_name = os.getenv("ISKPRINTER_POSTGRES_DATABASE_NAME")
    postgres_hostname = os.getenv("ISKPRINTER_POSTGRES_HOSTNAME")

    with psycopg.connect(
        autocommit=True,
        dbname=database_name,
        host=postgres_hostname,
        password=postgres_password,
        port=5432,
        user=postgres_username,
    ) as conn:
        LOG.info("Connected to the database '%s'.", database_name)
        LOG.info("Populating the database...")

    iskprinter_database_uri = f"postgresql://{postgres_username}:{postgres_password}@{postgres_hostname}/{database_name}"

if __name__ == "__main__":
    main()
