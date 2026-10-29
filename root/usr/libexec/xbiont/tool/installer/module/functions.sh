#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# functions: common calls for installer tool

x::install_check_cancel() {
    local exit_code=$1
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi
}

x::install_progress() {
    jq -cn --arg step "${X_INSTALL_STEP:-}" --argjson percent "$1" --arg message "$2" '{version:1,type:"progress",step:$step,percent:$percent,message:$message}'
}

x::install_exec() {
    # stdout carries JSON events, so log via stderr
    [ "$X_INSTALL_EXECUTION" = dryrun ] || return 1
    jq -cn --args '$ARGS.positional | {version:1,type:"command",argv:.}' -- "$@"
    x::log_info "dryrun: $*" >&2
    sleep 0.1
}

x::install_error() {
    jq -cn --arg code "$1" --arg message "$2" '{version:1,type:"error",code:$code,message:$message}'
}

x::install_targets() {
    lsblk --json --list --bytes --paths --exclude 7,11 --output NAME,SIZE,TYPE,PARTTYPE,MOUNTPOINTS,LABEL,PARTLABEL,MODEL,FSTYPE,PKNAME |
        jq -c '{version:1,type:"targets",targets:[.blockdevices[] | select(.type == "disk" or .type == "part") | select(.name | contains("zram") | not) | select(.type == "disk" or (((.mountpoints // []) | map(select(. != null and . != "")) | length) == 0 and ((.parttype // "") | ascii_downcase) != "c12a7328-f81f-11d2-ba4b-00a0c93ec93b")) | {path:.name,kind:.type,size_bytes:(.size|tonumber),description:(.label // .partlabel // .model // ""),filesystem:.fstype,parent:.pkname} ]}'
}

x::install_target_type() {
    lsblk -dnlo TYPE "/dev/$X_INSTALL_PARTITION_NAME" 2>/dev/null
}

x::install_target_disk() {
    if [ "$(x::install_target_type)" == "disk" ]; then
        echo "/dev/$X_INSTALL_PARTITION_NAME"
    else
        lsblk -dnlo PKNAME "/dev/$X_INSTALL_PARTITION_NAME" 2>/dev/null | sed 's|^|/dev/|'
    fi
}

x::install_partition_path() {
    local disk=$1
    local number=$2
    case "$disk" in
    *nvme*|*mmcblk*) echo "${disk}p${number}" ;;
    *) echo "${disk}${number}" ;;
    esac
}

x::install_root_partition() {
    if [ "$(x::install_target_type)" == "disk" ]; then
        x::install_partition_path "$(x::install_target_disk)" 2
    else
        echo "/dev/$X_INSTALL_PARTITION_NAME"
    fi
}

x::install_esp_partition() {
    local disk=$(x::install_target_disk)
    if [ "$(x::install_target_type)" == "disk" ]; then
        x::install_partition_path "$disk" 1
    else
        lsblk -nlo NAME,PARTTYPE "$disk" 2>/dev/null \
            | awk 'tolower($2) == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" { print "/dev/" $1; exit }'
    fi
}
