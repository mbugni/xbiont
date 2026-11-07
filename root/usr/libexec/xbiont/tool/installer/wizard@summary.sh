#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/wizard@summary: validate the installation plan

x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_LIVE_IMAGE' "/dev/mapper/live-base"
x::export_with_default 'X_INSTALL_ESP_SIZE' "268435456"

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

# The target device must not be in use: check the selected partition, or the
# whole disk and its children for a disk selection. Mounts under our own
# target root are leftovers of previous runs and are cleaned later on.
install_target_disk=$(x::install_target_disk)
if [ "$(x::install_target_type)" = "disk" ]; then
    busy_devices=$(lsblk -lnpo NAME "$install_target_disk" 2>/dev/null || true)
else
    busy_devices="/dev/$X_INSTALL_PARTITION_NAME"
fi
busy_mount=$(
    for device in $busy_devices; do
        findmnt -rn -o TARGET -S "$device" 2>/dev/null
    done | grep -v "^$X_INSTALL_TARGET_ROOT" | head -n1 || true
)
if [ -n "$busy_mount" ]; then
    x::install_error target_busy "The selected device is in use (mounted at $busy_mount)"
    exit 1
fi

# The target must not be the device the live system booted from
boot_source=$(findmnt -nro SOURCE /run/initramfs/live 2>/dev/null | head -n1 || true)
if [ -n "$boot_source" ]; then
    boot_disk=$(lsblk -dnpo PKNAME "$boot_source" 2>/dev/null | head -n1 || true)
    [ -n "$boot_disk" ] || boot_disk="$boot_source"
    if [ "$boot_disk" = "$install_target_disk" ]; then
        x::install_error target_is_live_media "The selected device contains the running live system"
        exit 1
    fi
fi

# The root partition must hold the uncompressed contents of the live image;
# measure it, skipping what does not land on the root partition: API
# filesystems, the ESP content (copied to the EFI partition), and boot
# files that are deleted and regenerated during the install
x::export_with_default 'X_INSTALL_LIVE_SOURCE' "/run/install-source"
required_size=''
image_mount=$(x::install_live_mount)
own_mount=''
if [ -z "$image_mount" ] && [ "$(id -u)" -eq 0 ] && [ -b "$X_INSTALL_LIVE_IMAGE" ]; then
    image_mount=$X_INSTALL_LIVE_SOURCE
    mkdir -p "$image_mount" && mount -o ro "$X_INSTALL_LIVE_IMAGE" "$image_mount" && own_mount=1
fi
if [ -n "$image_mount" ] && [ -d "$image_mount" ]; then
    required_size=$(du --bytes --summarize \
        --exclude='dev' --exclude='proc' --exclude='sys' --exclude='run' --exclude='tmp/*' \
        --exclude='boot/efi' --exclude='boot/loader' --exclude='boot/*rescue*' \
        "$image_mount" 2>/dev/null | cut -f1 || true)
fi
if [ -n "$own_mount" ]; then
    umount -l "$image_mount" 2>/dev/null || true
fi

capacity_size=$(jq -r '.size_bytes - (if .kind == "disk" then 270532608 else 0 end)' <<< "$target")
if [[ "$required_size" =~ ^[0-9]+$ ]]; then
    # Headroom over the pure image size for regenerated initramfs, boot
    # artifacts, filesystem metadata and first-boot writes
    x::export_with_default 'X_INSTALL_SIZE_MARGIN' "10"
    required_size=$(( required_size + required_size * X_INSTALL_SIZE_MARGIN / 100 ))
    if [ "$capacity_size" -lt "$required_size" ]; then
        x::install_error insufficient_space "The proposed root partition is too small for the live image"
        exit 1
    fi
else
    warnings=$(jq -cn '["Live image size could not be measured; root capacity cannot be verified."]')
fi

# Boot-mode checks
if [ "$X_INSTALL_BOOT_TYPE" = UEFI ]; then
    if [ ! -d /sys/firmware/efi ]; then
        warnings=$(jq -c '. + ["The system was not booted in UEFI mode; a UEFI bootloader may not be registered."]' <<< "$warnings")
    fi
    if [ "$(jq -r .kind <<< "$target")" = part ]; then
        install_esp_partition=$(x::install_esp_partition)
        if [ -z "$install_esp_partition" ]; then
            x::install_error missing_esp "No EFI System Partition found on the target disk"
            exit 1
        fi
        esp_size=$(lsblk -bdnlo SIZE "$install_esp_partition" 2>/dev/null || true)
        if [[ "$esp_size" =~ ^[0-9]+$ ]]; then
            if [ "$esp_size" -lt 67108864 ]; then
                x::install_error esp_too_small "The EFI System Partition is too small (${esp_size} bytes)"
                exit 1
            elif [ "$esp_size" -lt "$X_INSTALL_ESP_SIZE" ]; then
                warnings=$(jq -c --arg esp "$install_esp_partition" '. + ["The EFI System Partition on \($esp) is smaller than the recommended 256 MiB."]' <<< "$warnings")
            fi
        fi
    fi
fi

case "$X_DISTRO_ID" in
debian) install_fs_type="ext4" ;;
*) install_fs_type="xfs" ;;
esac
jq -cn \
    --argjson target "$target" \
    --arg boot "$X_INSTALL_BOOT_TYPE" \
    --arg fs "$install_fs_type" \
    --argjson warnings "$warnings" \
    '{
        version: 1,
        type: "plan",
        target: $target,
        boot_mode: $boot,
        execution: "dryrun",
        filesystem: $fs,
        layout: (if $target.kind == "disk"
            then "Fresh GPT · 256 MiB ESP · remaining space for root"
            else "Format selected partition as root" end),
        warning: (if $target.kind == "disk"
            then "A real installation would erase the selected disk."
            else "A real installation would format the selected root partition." end),
        warnings: $warnings
    }'
