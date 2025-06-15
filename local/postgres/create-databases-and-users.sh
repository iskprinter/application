#!/usr/bin/env bash

set -eu -o pipefail

# No password is needed when connecting via a local unix socket.
admin_username="${POSTGRES_USER}"
readonly ADMIN_DATABASE_NAME='postgres'

function create_db {
    local db_name="${1}"
    run_sql_command "${ADMIN_DATABASE_NAME}" "CREATE DATABASE \"${db_name}\";"
}

function create_user {
    local username="${1}"
    local password="${2}"
    run_sql_command "${ADMIN_DATABASE_NAME}" "CREATE USER \"${username}\" WITH PASSWORD '${password}';"
}

function db_exists {
	local db_name="${1}"
    run_sql_command "${ADMIN_DATABASE_NAME}" "SELECT 1 FROM pg_database WHERE datname = '${db_name}';" \
	| grep -q 1
}

function run_sql_command {
    local -r database_name="${1}"
    local -r command="${2}"
    # Connection will implicitly be made to the unix socket.
    psql \
        --command "${command}" \
        --dbname "${database_name}" \
        --tuples-only \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1
}

function user_exists {
    local user_name="${1}"
    run_sql_command "${ADMIN_DATABASE_NAME}" "SELECT 1 FROM pg_roles WHERE rolname = '${user_name}';" \
    | grep -q 1
}

# # Wait for postgres to be ready.
# echo "Waiting for postgres to be ready..."
# for _ in $(seq 0 30); do
#     if pg_isready >/dev/null; then
#         echo "Postgres is ready."
#         break;
#     fi
#     echo "Postgres is not ready yet. Waiting..."
#     sleep 1
# done

# Create database 'iskprinter'.
db_name="${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}"
if db_exists "${db_name}"; then
    echo "Database '${db_name}' already exists. Skipping creation."
else 
    echo "Creating database '${db_name}'..."
    create_db "${db_name}"
fi

# Create database 'superset'.
db_name="${ISKPRINTER_POSTGRES_DATABASE_SUPERSET_NAME}"
if db_exists "${db_name}"; then
    echo "Database '${db_name}' already exists. Skipping creation."
else 
    echo "Creating database '${db_name}'..."
    create_db "${db_name}"
fi

# Create user 'data-downloader'.
username="$(cat "${ISKPRINTER_POSTGRES_USER_DATA_DOWNLOADER_USERNAME_PATH}")"
password="$(cat "${ISKPRINTER_POSTGRES_USER_DATA_DOWNLOADER_PASSWORD_PATH}")"
if user_exists "${username}"; then
    echo "User '${username}' already exists. Skipping creation."
else
    echo "Creating user '${username}'..."
    create_user "${username}" "${password}"
fi
echo "Running 'GRANT CONNECT ON DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}\" TO \"${username}\";'..."
run_sql_command "${ADMIN_DATABASE_NAME}" "GRANT CONNECT ON DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}\" TO \"${username}\";"
echo "Running 'GRANT CREATE, USAGE ON SCHEMA public TO \"${username}\";'..."
run_sql_command "${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}" "GRANT CREATE, USAGE ON SCHEMA public TO \"${username}\";"

# Create user 'superset'.
username="$(cat "${ISKPRINTER_POSTGRES_USER_SUPERSET_USERNAME_PATH}")"
password="$(cat "${ISKPRINTER_POSTGRES_USER_SUPERSET_PASSWORD_PATH}")"
if user_exists "${username}"; then
    echo "User '${username}' already exists. Skipping creation."
else
    echo "Creating user '${username}'..."
    create_user "${username}" "${password}"
fi
echo "Running 'ALTER DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_SUPERSET_NAME}\" OWNER TO \"${username}\";'..."
run_sql_command "${ADMIN_DATABASE_NAME}" "ALTER DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_SUPERSET_NAME}\" OWNER TO \"${username}\";"
echo "Running 'GRANT CONNECT ON DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}\" TO \"${username}\";'..."
run_sql_command "${ADMIN_DATABASE_NAME}" "GRANT CONNECT ON DATABASE \"${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}\" TO \"${username}\";"
