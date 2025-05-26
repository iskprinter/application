#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${1}"

cd "${WORKDIR}"
python -m venv ./venv
# shellcheck disable=SC1091
source ./venv/bin/activate
trap 'deactivate' EXIT
pip install pip \
    --quiet \
    --upgrade
pip install \
    --requirement ./src/requirements.txt\
    --quiet
python ./src
