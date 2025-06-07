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
        file=os.getenv("ISKPRINTER_DATABASE_USERNAME_PATH"),
        mode="r",
        encoding="utf-8",
    ) as f:
        database_username = f.read().strip()

    with open(
        file=os.getenv("ISKPRINTER_DATABASE_PASSWORD_PATH"),
        mode="r",
        encoding="utf-8",
    ) as f:
        database_password = f.read().strip()

    database_name = os.getenv("ISKPRINTER_DATABASE_NAME")
    database_hostname = os.getenv("ISKPRINTER_DATABASE_HOSTNAME")

    with psycopg.connect(
        autocommit=True,
        dbname=database_name,
        host=database_hostname,
        password=database_password,
        port=5432,
        user=database_username,
    ) as conn:
        LOG.info("Connected to the database '%s'.", database_name)
        LOG.info("Populating the database...")

    iskprinter_database_uri = f"postgresql://{database_username}:{database_password}@{database_hostname}/{database_name}"

if __name__ == "__main__":
    main()
