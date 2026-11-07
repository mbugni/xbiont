#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/wizard@request: dispatch a noninteractive backend request

set -eE -o pipefail
trap 'x::install_error backend_failure "Backend request failed"' ERR
case "${X_INSTALL_REQUEST:-}" in
partition|boot|summary|install) step=$X_INSTALL_REQUEST ;;
*) x::install_error invalid_request "Unknown wizard request"; exit 1 ;;
esac
request=$(cat)
jq -e 'type == "object" and ((keys - ["target","boot_mode","execution"]) | length == 0) and all(.[]; type == "string")' <<< "$request" >/dev/null
export X_INSTALL_EXECUTION=$(jq -r '.execution // "dryrun"' <<< "$request")
if [ "$X_INSTALL_EXECUTION" != dryrun ]; then
    x::install_error invalid_mode "Only dryrun is supported"
    exit 1
fi
export X_INSTALL_PARTITION_NAME=$(jq -r '.target // "" | ltrimstr("/dev/")' <<< "$request")
export X_INSTALL_BOOT_TYPE=$(jq -r '.boot_mode // ""' <<< "$request")

# The install step requires elevated privileges: the frontend stays
# unprivileged, so the backend re-executes itself through pkexec. The
# request is validated above, before any authorization is requested, and
# X_INSTALL_ELEVATED marks the privileged re-entry to avoid recursion.
if [ "$step" = install ] && [ "${X_INSTALL_ELEVATED:-}" != "1" ] && [ "$(id -u)" -ne 0 ]; then
    if ! command -v pkexec > /dev/null; then
        x::install_error elevation_unavailable "pkexec is required to authorize the installation"
        exit 1
    fi
    x::install_log "Requesting authorization for the installation..."
    pkexec "$X_PULSE_DIR/xbiont" run installer \
        X_ACTIONABLE_LOG_MODE=split X_INSTALL_REQUEST=install X_INSTALL_ELEVATED=1 <<< "$request" \
        || elevation_status=$?
    case "${elevation_status:-0}" in
    0) ;;
    126)
        x::install_error authorization_denied "Installation authorization was denied or cancelled"
        exit 126
        ;;
    127)
        x::install_error elevation_failed "Unable to obtain the required authorization"
        exit 127
        ;;
    *) exit "$elevation_status" ;;
    esac
    exit 0
fi

source "$X_ACTIONABLE_DIR/wizard@$step.sh"
