#!/usr/bin/bash

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
export X_DISTRO_ID=fedora
source "$X_ACTIONABLE_DIR/wizard@$step.sh"
