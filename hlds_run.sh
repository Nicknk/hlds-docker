#!/usr/bin/env bash

set -axe

CONFIG_FILE="/opt/hlds/startup.cfg"

if [ -r "${CONFIG_FILE}" ]; then
    # TODO: make config save/restore mechanism more solid
    set +e
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
    set -e
fi

EXTRA_OPTIONS=( "$@" )

EXECUTABLE="/opt/hlds/hlds_run"
GAME="${GAME:-cstrike}"
MAXPLAYERS="${MAXPLAYERS:-20}"
START_MAP="${START_MAP:-bounce}"
SERVER_NAME="${SERVER_NAME:-'Counter Strike 1.6 Server'}"
INSECURE="${INSECURE:-}"
NOMASTERS="${NOMASTERS:-}"

OPTIONS=( "-game" "${GAME}" "+maxplayers" "${MAXPLAYERS}" "+map" "${START_MAP}" "+hostname" "\"${SERVER_NAME}\"" "${INSECURE}" "${NOMASTERS}")

if [ -z "${RESTART_ON_FAIL}" ]; then
    OPTIONS+=('-norestart')
fi

if [ -n "${ADMIN_STEAM}" ]; then
    echo "\"STEAM_${ADMIN_STEAM}\" \"\"  \"abcdefghijklmnopqrstu\" \"ce\"" >> "/opt/hlds/cstrike/addons/amxmodx/configs/users.ini"
fi

set > "${CONFIG_FILE}"

exec python3 -m http.server --directory /opt/hlds/cstrike 80 &
exec "${EXECUTABLE}" "${OPTIONS[@]}" "${EXTRA_OPTIONS[@]}"
