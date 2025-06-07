import os

with open(
    encoding="utf-8",
    file=os.getenv("ISKPRINTER_POSTGRES_USERNAME_PATH"),
    mode="r",
) as f:
    postgres_username = f.read().strip()

with open(
    encoding="utf-8",
    file=os.getenv("ISKPRINTER_POSTGRES_PASSWORD_PATH"),
    mode="r",
) as f:
    postgres_password = f.read().strip()

database_name = os.getenv("ISKPRINTER_POSTGRES_DATABASE_NAME")
postgres_hostname = os.getenv("ISKPRINTER_POSTGRES_HOSTNAME")
SQLALCHEMY_DATABASE_URI = f"postgresql://{postgres_username}:{postgres_password}@{postgres_hostname}/{database_name}"

with open(
    encoding="utf-8",
    file=os.getenv("SUPERSET_SECRET_KEY_PATH"),
    mode="r",
) as f:
    SECRET_KEY = f.read().strip()
