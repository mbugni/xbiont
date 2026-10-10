#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@partition: run the image installer partition selection

partition_msg="Choose the target partition for the new installation:"

function x::get_partition_attribute() {
    local partition_name=$1
    local partition_attribute=$2
    echo "$(lsblk -dpnlo "$partition_attribute" "/dev/$partition_name" 2>/dev/null)"
}

# Get partition list, excluding:
# - zram devices
# - loop devices
# - boot partitions
# - currently mounted filesystems
partition_map=$(lsblk -nlo NAME,SIZE,TYPE,PARTTYPE -e 7,11 | awk '{print $1, "["$2"]", $3, $4}')
partition_menu=()
while read -r partition_name partition_size device_type partition_type; do
    # Exclude zram devices
    if [[ "$partition_name" == *zram* ]]; then
        continue
    fi
    partition_mount=$(x::get_partition_attribute "$partition_name" "MOUNTPOINT")
    partition_label=""
    # Exclude currently mounted filesystems but keep disks
    case "$device_type" in
    part)
        if [ -n "$partition_mount" ]; then
            continue
        fi
        # Exclude ESP boot partitions
        if [ "$partition_type" = 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' ]; then
            continue
        fi
        partition_label=$(x::get_partition_attribute "$partition_name" "LABEL")
        if [ -z "$partition_label" ]; then
            partition_label=$(x::get_partition_attribute "$partition_name" "PARTLABEL")
        fi
        partition_fs_type=$(x::get_partition_attribute "$partition_name" "FSTYPE")
        printf -v partition_fs_type "%7s" "$partition_fs_type"
        partition_label=$partition_fs_type'  ['$partition_label']'
        ;;
    disk)
        printf -v device_type "%7s" "$device_type"
        partition_label=$device_type'  ['$(x::get_partition_attribute "$partition_name" "MODEL")']'
        ;;
    *)
        continue
        ;;
    esac
    partition_desc=$(x::get_partition_attribute "$partition_name" "SIZE")
    partition_desc+=" $partition_label"
    partition_menu+=("$partition_name" "$partition_desc")
done <<< "$partition_map"

partition_target=$(dialog --stdout \
    --title " Installation Target " \
    --menu "$partition_msg" 15 75 5 \
    "${partition_menu[@]}" \
    </dev/tty)
x::install_check_cancel

echo "$partition_target"
