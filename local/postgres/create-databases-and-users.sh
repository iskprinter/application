#!/usr/bin/env bash

set -eu -o pipefail

admin_username="$(cat "${POSTGRES_USER_FILE}")"

function create_db {
    local db_name="${1}"
    psql \
        --command "CREATE DATABASE \"${db_name}\";" \
        --host localhost \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1
}

function create_user {
    local username="${1}"
    local password="${2}"
    psql \
        --command "CREATE USER \"${username}\" WITH PASSWORD '${password}';" \
        --host localhost \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1
}

function db_exists {
	local db_name="${1}"
    psql \
        --command "SELECT 1 FROM pg_database WHERE datname = '${db_name}'" \
        --no-align \
        --tuples-only \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1 \
	| grep -q 1
}

function grant_privileges {
    local username="${1}"
    local db_name="${2}"
    local privileges="${3}"
    psql \
        --command "GRANT ${privileges} ON DATABASE \"${db_name}\" TO \"${username}\";" \
        --host localhost \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1
}

function user_exists {
    local user_name="${1}"
    psql \
        --command "SELECT 1 FROM pg_roles WHERE rolname = '${user_name}'" \
        --no-align \
        --tuples-only \
        --username "${admin_username}" \
        --variable ON_ERROR_STOP=1 \
    | grep -q 1
}

# Wait for postgres to be ready.
echo "Waiting for postgres to be ready..."
for _ in $(seq 0 30); do
    if pg_isready >/dev/null; then
        echo "Postgres is ready."
        break;
    fi
    echo "Postgres is not ready yet. Waiting..."
    sleep 1
done

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

# Create user 'database-populator'.
username="$(cat "${ISKPRINTER_POSTGRES_USER_DATABASE_POPULATOR_USERNAME_PATH}")"
password="$(cat "${ISKPRINTER_POSTGRES_USER_DATABASE_POPULATOR_PASSWORD_PATH}")"
db_privileges_iskprinter='CONNECT'
if user_exists "${username}"; then
    echo "User '${username}' already exists. Skipping creation."
else
    echo "Creating user '${username}'..."
    create_user "${username}" "${password}"
fi
echo "Granting privileges '${db_privileges_iskprinter}' to user '${username}' on database '${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}'..."
grant_privileges "${username}" "${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}" "${db_privileges_iskprinter}"

# Create user 'superset'.
username="$(cat "${ISKPRINTER_POSTGRES_USER_SUPERSET_USERNAME_PATH}")"
password="$(cat "${ISKPRINTER_POSTGRES_USER_SUPERSET_PASSWORD_PATH}")"
db_privileges_iskprinter='CONNECT'
db_privileges_superset='CONNECT'
if user_exists "${username}"; then
    echo "User '${username}' already exists. Skipping creation."
else
    echo "Creating user '${username}'..."
    create_user "${username}" "${password}"
fi
echo "Granting privileges '${db_privileges_iskprinter}' to user '${username}' on database '${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}'..."
grant_privileges "${username}" "${ISKPRINTER_POSTGRES_DATABASE_ISKPRINTER_NAME}" "${db_privileges_iskprinter}"
echo "Granting privileges '${db_privileges_superset}' to user '${username}' on database '${ISKPRINTER_POSTGRES_DATABASE_SUPERSET_NAME}'..."
grant_privileges "${username}" "${ISKPRINTER_POSTGRES_DATABASE_SUPERSET_NAME}" "${db_privileges_superset}"
echo
