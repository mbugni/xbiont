#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@summary: show installation summary

target=$(x::install_targets | jq -c --arg path "/dev/$X_INSTALL_PARTITION_NAME" '.targets[] | select(.path == $path)')
if [ -z "$target" ]; then
    x::install_error invalid_target "Select an eligible storage device"
    exit 1
fi
case "$X_INSTALL_BOOT_TYPE" in
UEFI|MBR|NONE) ;;
*) x::install_error invalid_boot "Select a supported boot mode"; exit 1 ;;
esac
warnings='[]'
image_size=$(lsblk -bdnlo SIZE /dev/mapper/live-base 2>/dev/null || true)
if [[ ! "$image_size" =~ ^[0-9]+$ ]]; then
    warnings=$(jq -cn '["Live image unavailable; root capacity cannot be verified. Preview is still available."]')
else
    capacity=$(jq -r '.size_bytes - (if .kind == "disk" then 270532608 else 0 end)' <<< "$target")
    if [ "$capacity" -lt "$image_size" ]; then
        warnings=$(jq -cn '["The proposed root partition may be too small for the live image. Preview is still available."]')
    fi
fi
if [ "$X_INSTALL_BOOT_TYPE" = UEFI ] && [ "$(jq -r .kind <<< "$target")" = part ] && [ -z "$(x::install_esp_partition)" ]; then
    warnings=$(jq -c '. + ["No ESP found on the target disk; real installation would require a suitable ESP layout."]' <<< "$warnings")
fi
jq -cn --argjson target "$target" --arg boot "$X_INSTALL_BOOT_TYPE" --argjson warnings "$warnings" '{version:1,type:"plan",target:$target,boot_mode:$boot,execution:"dryrun",filesystem:"xfs",layout:(if $target.kind == "disk" then "Fresh GPT · 256 MiB ESP · remaining space for root" else "Format selected partition as root" end),warning:(if $target.kind == "disk" then "A real installation would erase the selected disk." else "A real installation would format the selected root partition." end),warnings:$warnings}'
