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

x::install_log() {
    # stdout carries JSON events, so diagnostics go to stderr
    x::log_info "$@" >&2
}

x::install_progress() {
    jq -cn --arg step "${X_INSTALL_STEP:-}" --argjson percent "$1" --arg message "$2" '{version:1,type:"progress",step:$step,percent:$percent,message:$message}'
}

x::install_error() {
    jq -cn --arg code "$1" --arg message "$2" '{version:1,type:"error",code:$code,message:$message}'
}

x::install_exec() {
    # Record every command for the frontend log, then run it unless the
    # execution mode is 'dryrun'. Command output must not pollute the JSON
    # event stream, so it is redirected to stderr.
    jq -cn --args '$ARGS.positional | {version:1,type:"command",argv:.}' -- "$@"
    if [ "$X_INSTALL_EXECUTION" = dryrun ]; then
        x::install_log "dryrun: $*"
        sleep 0.1
        return 0
    fi
    x::install_log "exec: $*"
    "$@" >&2
}

x::install_write_file() {
    # Write stdin to a file in the target; logged like a regular command.
    local path=$1
    local content
    content=$(cat)
    if [ "$X_INSTALL_EXECUTION" = dryrun ]; then
        x::install_exec tee "$path"
        return 0
    fi
    jq -cn --arg path "$path" '{version:1,type:"command",argv:["tee",$path]}'
    x::install_log "write: $path"
    printf '%s' "$content" > "$path"
}

# State shared between install steps (each step runs in its own subshell,
# so values like filesystem UUIDs are persisted through a state file).
x::install_state_load() {
    x::export_with_default 'X_INSTALL_STATE_FILE' "/tmp/xbiont-install-state.env"
    [ -r "$X_INSTALL_STATE_FILE" ] && source "$X_INSTALL_STATE_FILE"
    return 0
}

x::install_state_set() {
    x::export_with_default 'X_INSTALL_STATE_FILE' "/tmp/xbiont-install-state.env"
    printf '%s=%q\n' "$1" "$2" >> "$X_INSTALL_STATE_FILE"
}

x::install_targets() {
    lsblk --json --list --bytes --paths --exclude 7,11 \
        --output NAME,SIZE,TYPE,PARTTYPE,MOUNTPOINTS,LABEL,PARTLABEL,MODEL,FSTYPE,PKNAME \
        | jq -c '{
            version: 1,
            type: "targets",
            targets: [.blockdevices[]
                | select(.type == "disk" or .type == "part")
                | select(.name | contains("zram") | not)
                | select(.type == "disk" or
                    (((.mountpoints // []) | map(select(. != null and . != "")) | length) == 0
                    and ((.parttype // "") | ascii_downcase) != "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"))
                | {
                    path: .name,
                    kind: .type,
                    size_bytes: (.size | tonumber),
                    description: (.label // .partlabel // .model // ""),
                    filesystem: .fstype,
                    parent: .pkname
                }]
        }'
}

x::install_target_type() {
    lsblk -dnlo TYPE "/dev/$X_INSTALL_PARTITION_NAME" 2>/dev/null || true
}

x::install_target_disk() {
    if [ "$(x::install_target_type)" == "disk" ]; then
        echo "/dev/$X_INSTALL_PARTITION_NAME"
    else
        lsblk -dnlo PKNAME "/dev/$X_INSTALL_PARTITION_NAME" 2>/dev/null | sed 's|^|/dev/|' || true
    fi
}

x::install_partition_path() {
    local disk=$1
    local number=$2
    case "$disk" in
    *nvme*|*mmcblk*|*loop*) echo "${disk}p${number}" ;;
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
            | awk 'tolower($2) == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" { print "/dev/" $1; exit }' || true
    fi
}

x::install_partition_number() {
    lsblk -dnlo PARTN "$1" 2>/dev/null | tr -d '[:space:]' || true
}

# Mountpoint of the live image, if already mounted by the live system
x::install_live_mount() {
    x::export_with_default 'X_INSTALL_LIVE_IMAGE' "/dev/mapper/live-base"
    findmnt -nro TARGET -S "$X_INSTALL_LIVE_IMAGE" 2>/dev/null | head -n1 || true
}

# Kernel versions available on a filesystem root (e.g. the installed target
# or the mounted live image), excluding rescue entries
x::install_kernel_versions() {
    local roots=("$1")
    local live_mount=$(x::install_live_mount)
    [ -n "$live_mount" ] && roots+=("$live_mount")
    local root image
    for root in "${roots[@]}"; do
        for image in "$root"/boot/vmlinuz-*; do
            [ -e "$image" ] || continue
            case "$image" in
            *-rescue-*|*-rescue) continue ;;
            esac
            basename "$image" | sed 's/^vmlinuz-//'
        done | sort -u
        [ -n "$(compgen -G "$root/boot/vmlinuz-*")" ] && return 0
    done
    return 0
}
