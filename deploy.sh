#!/bin/bash

set -euo pipefail

NAMESPACE='iskprinter'
RELEASE_NAME='iskprinter'

other_args=()

for i in "$@"; do
    case $i in
        --client-id=*)
        CLIENT_ID="${i#*=}"
        ;;
        --client-secret=*)
        CLIENT_SECRET="${i#*=}"
        ;;
        --host=*)
        HOST="${i#*=}"
        ;;
        --kube-context=*)
        KUBE_CONTEXT="${i#*=}"
        ;;
        --mongo-initdb-root-password=*)
        MONGO_INITDB_ROOT_PASSWORD="${i#*=}"
        ;;
        *)
        other_args+=("$i")
        ;;
    esac
    shift
done

deploy_command='upgrade'
if ! helm status "$RELEASE_NAME" "${KUBE_CONTEXT:+"--kube-context ${KUBE_CONTEXT}"}" -n "$NAMESPACE" &>/dev/null; then
    deploy_command='install'
fi

helm "$deploy_command" "$RELEASE_NAME" ./helm \
    "${KUBE_CONTEXT:+"--kube-context ${KUBE_CONTEXT}"}" \
    -n "$NAMESPACE" \
    --set "api.clientId=${CLIENT_ID}" \
    --set "api.clientSecret=${CLIENT_SECRET}" \
    --set "database.mongoInitdbRootPassword=${MONGO_INITDB_ROOT_PASSWORD}" \
    --set "host=${HOST}" \
    $(if [ ${#other_args[@]} -gt 0 ]; then echo "${other_args[@]}"; fi)
